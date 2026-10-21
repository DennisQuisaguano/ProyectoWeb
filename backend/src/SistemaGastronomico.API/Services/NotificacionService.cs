using Microsoft.AspNetCore.SignalR;
using SistemaGastronomico.API.Hubs;
using SistemaGastronomico.Application.Common.Interfaces;
using SistemaGastronomico.Domain.Entities;

namespace SistemaGastronomico.API.Services;

public class NotificacionService : INotificacionService
{
    private readonly IHubContext<NotificacionesHub> _hubContext;
    private readonly IApplicationDbContext _dbContext;

    public NotificacionService(IHubContext<NotificacionesHub> hubContext, IApplicationDbContext dbContext)
    {
        _hubContext = hubContext;
        _dbContext = dbContext;
    }

    public async Task SendNotificacionAsync(Guid usuarioId, string tipo, string mensaje, CancellationToken cancellationToken = default)
    {
        var notificacion = new Notificacion
        {
            UsuarioId = usuarioId,
            Tipo = tipo,
            Mensaje = mensaje,
            Leida = false,
            CreatedAt = DateTime.UtcNow
        };

        _dbContext.Notificaciones.Add(notificacion);
        await _dbContext.SaveChangesAsync(cancellationToken);

        await _hubContext.Clients.Group(usuarioId.ToString()).SendAsync("ReceiveNotification", notificacion, cancellationToken);
    }

    public async Task NotificarAdminsAsync(string tipo, string mensaje, CancellationToken cancellationToken = default)
    {
        var admins = _dbContext.Usuarios.Where(u => u.Rol == SistemaGastronomico.Domain.Enums.RolUsuario.Administrador);
        foreach (var admin in admins)
        {
            await SendNotificacionAsync(admin.Id, tipo, mensaje, cancellationToken);
        }
    }

    public async Task NotificarEstudiantesAsync(string tipo, string mensaje, CancellationToken cancellationToken = default)
    {
        // 1. Guardar notificación para cada estudiante registrado
        var estudiantes = _dbContext.Usuarios
            .Where(u => u.Rol == SistemaGastronomico.Domain.Enums.RolUsuario.Estudiante && u.IsActive)
            .ToList();

        var notificaciones = estudiantes.Select(e => new Notificacion
        {
            UsuarioId = e.Id,
            Tipo = tipo,
            Mensaje = mensaje,
            Leida = false,
            CreatedAt = DateTime.UtcNow
        }).ToList();

        if (notificaciones.Any())
        {
            _dbContext.Notificaciones.AddRange(notificaciones);
            await _dbContext.SaveChangesAsync(cancellationToken);
        }

        // 2. Broadcast en tiempo real vía SignalR a todos los clientes conectados
        var notifBroadcast = new
        {
            tipo = tipo,
            mensaje = mensaje,
            createdAt = DateTime.UtcNow
        };
        await _hubContext.Clients.All.SendAsync("ReceiveNotification", notifBroadcast, cancellationToken);
    }
}
