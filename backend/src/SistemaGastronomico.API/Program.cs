using Microsoft.AspNetCore.RateLimiting;
using System.Threading.RateLimiting;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using SistemaGastronomico.API.Middlewares;
using SistemaGastronomico.Application;
using SistemaGastronomico.Application.Common.Interfaces;
using SistemaGastronomico.Domain.Entities;
using SistemaGastronomico.Domain.Enums;
using SistemaGastronomico.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container (Clean Architecture layers)
builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);

// Exception handling and problem details
builder.Services.AddExceptionHandler<CustomExceptionHandler>();
builder.Services.AddProblemDetails();

// CORS for Blazor WASM and other clients
builder.Services.AddCors(options =>
{
    options.AddPolicy("FrontendPolicy", policy =>
    {
        policy.WithOrigins(builder.Configuration.GetSection("AllowedOrigins").Get<string[]>() ?? new[] { "http://localhost:5098", "https://localhost:7098", "http://localhost:5169", "http://localhost:5000", "https://localhost:7169" })
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials(); // Mayor seguridad
    });
});

// Agregar Rate Limiting para evitar abusos (DDoS, Pruebas de Carga descontroladas)
builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    options.AddFixedWindowLimiter("GlobalPolicy", opt =>
    {
        opt.PermitLimit = 50; // 50 requests por ventana
        opt.Window = TimeSpan.FromSeconds(10);
        opt.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
        opt.QueueLimit = 2;
    });
});

builder.Services.AddControllers();

// SignalR y Notificaciones
builder.Services.AddSignalR();
builder.Services.AddScoped<INotificacionService, SistemaGastronomico.API.Services.NotificacionService>();

// Configuración exclusiva de Swagger con Swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Sistema Gastronómico UTA - Web API",
        Version = "v1",
        Description = "API REST de la Plataforma de Recomendación y Descubrimiento de Locales de Comida Basada en Geolocalización para la Comunidad de la UTA."
    });

    // Configuración para autorizar con JWT en Swagger UI
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "Autenticación JWT usando el esquema Bearer. \r\n\r\n Ingrese 'Bearer' [espacio] y luego su token en el campo.\r\n\r\nEjemplo: \"Bearer eyJhbGciOi...\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                },
                Scheme = "oauth2",
                Name = "Bearer",
                In = ParameterLocation.Header
            },
            new List<string>()
        }
    });
});

var app = builder.Build();

// Enable CORS for all clients (must be before ExceptionHandler and HttpsRedirection)
app.UseCors("FrontendPolicy");

// Enable Rate Limiting
app.UseRateLimiter();

// Serve uploaded static files (certificados, imágenes)
app.UseStaticFiles();

// Exception handling and problem details
app.UseExceptionHandler();

// Enable Swagger and classic Swagger UI
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Sistema Gastronómico UTA API v1");
        c.RoutePrefix = "swagger";
    });
}
else
{
    app.UseHttpsRedirection();
}

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers().RequireRateLimiting("GlobalPolicy");

// Map SignalR Hub
app.MapHub<SistemaGastronomico.API.Hubs.NotificacionesHub>("/hubs/notificaciones");

// Seed usuario administrador por defecto si no existe ninguno
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<IApplicationDbContext>();
    var passwordHasher = scope.ServiceProvider.GetRequiredService<IPasswordHasher>();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();

    try
    {
        if (!await context.Usuarios.AnyAsync(u => u.Rol == RolUsuario.Administrador))
        {
            var admin = new Usuario
            {
                NombreCompleto = "Administrador UTA",
                Email = "admin@uta.edu.ec",
                PasswordHash = passwordHasher.HashPassword("Admin123!"),
                Telefono = "0999999999",
                Rol = RolUsuario.Administrador,
                IsActive = true
            };
            context.Usuarios.Add(admin);
            await context.SaveChangesAsync(CancellationToken.None);
            logger.LogInformation(">>> Usuario Administrador inicial creado con éxito: admin@uta.edu.ec / Admin123!");
        }
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Error al verificar o inicializar el usuario administrador.");
    }
}

app.Run();
