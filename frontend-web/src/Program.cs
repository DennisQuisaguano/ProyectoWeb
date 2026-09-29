using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using src;
using src.Services;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

var apiBaseUrl = builder.Configuration["ApiBaseUrl"] ?? "http://localhost:5050/";
builder.Services.AddTransient<AuthHeaderHandler>();
builder.Services.AddScoped(sp =>
{
    var authHandler = sp.GetRequiredService<AuthHeaderHandler>();
    authHandler.InnerHandler = new HttpClientHandler();
    return new HttpClient(authHandler) { BaseAddress = new Uri(apiBaseUrl) };
});

builder.Services.AddAuthorizationCore();
builder.Services.AddScoped<AuthenticationStateProvider, CustomAuthStateProvider>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<LocalService>();
builder.Services.AddScoped<MenuService>();
builder.Services.AddScoped<PromocionService>();
builder.Services.AddScoped<EstadisticasService>();
builder.Services.AddScoped<AdminService>();
builder.Services.AddScoped<NotificationService>();

await builder.Build().RunAsync();
