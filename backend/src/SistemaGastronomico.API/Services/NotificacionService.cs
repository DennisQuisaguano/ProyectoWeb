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
}
