namespace SistemaGastronomico.Application.Admin.Commands.ToggleLocalEstadoOperativo;

using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Admin;
using SistemaGastronomico.Application.Common.Exceptions;
using SistemaGastronomico.Application.Common.Interfaces;

public record ToggleLocalEstadoOperativoCommand(
    Guid LocalId,
    bool Habilitar,
    string? Motivo = null
) : IRequest<LocalAdminDto>;

public class ToggleLocalEstadoOperativoCommandHandler : IRequestHandler<ToggleLocalEstadoOperativoCommand, LocalAdminDto>
{
    private readonly IApplicationDbContext _context;
    private readonly INotificacionService _notificacionService;

    public ToggleLocalEstadoOperativoCommandHandler(
        IApplicationDbContext context,
        INotificacionService notificacionService)
    {
        _context = context;
        _notificacionService = notificacionService;
    }

    public async Task<LocalAdminDto> Handle(ToggleLocalEstadoOperativoCommand request, CancellationToken cancellationToken)
    {
        var local = await _context.Locales
            .Include(l => l.Propietario)
            .Include(l => l.RevisadoPor)
            .Include(l => l.Resenas)
            .FirstOrDefaultAsync(l => l.Id == request.LocalId, cancellationToken);

        if (local == null)
        {
            throw new NotFoundException("Local", request.LocalId);
        }

        // Habilitar o Deshabilitar
        local.EstaAbierto = request.Habilitar;
        local.UpdatedAt = DateTime.UtcNow;

        // Bloquear completamente al dueño si un admin lo deshabilita
        if (!request.Habilitar)
        {
            local.EstadoAprobacion = Domain.Enums.EstadoAprobacionLocal.Rechazado;
            if (!string.IsNullOrWhiteSpace(request.Motivo))
            {
                local.MotivoRechazo = request.Motivo;
            }
        }
        else
        {
            local.EstadoAprobacion = Domain.Enums.EstadoAprobacionLocal.Aprobado;
            local.MotivoRechazo = null;
        }

        await _context.SaveChangesAsync(cancellationToken);

        // Notificar al dueño por campanita (SignalR)
        if (local.PropietarioId != Guid.Empty)
        {
            var notifTipo = request.Habilitar ? "success" : "error";
            var notifMensaje = request.Habilitar
                ? $"Tu local '{local.Nombre}' ha sido habilitado por el administrador."
                : $"Tu local '{local.Nombre}' ha sido deshabilitado. Motivo: {request.Motivo ?? "Revisión administrativa."}";

            await _notificacionService.SendNotificacionAsync(local.PropietarioId, notifTipo, notifMensaje, cancellationToken);
        }

        var validResenas = local.Resenas.Where(r => r.IsActive).ToList();
        var totalResenas = validResenas.Count;
        var calificacionPromedio = totalResenas > 0 ? Math.Round(validResenas.Average(r => r.Calificacion), 1) : 0.0;

        return new LocalAdminDto(
            local.Id,
            local.Nombre,
            local.Descripcion,
            local.Direccion,
            local.Referencia,
            local.CampusCercano,
            local.Categoria,
            local.EstaAbierto,
            local.IsActive,
            local.Latitud,
            local.Longitud,
            local.TelefonoContacto,
            local.WhatsApp,
            local.HorarioApertura,
            local.LogoUrl,
            local.PortadaUrl,
            local.PropietarioId,
            local.Propietario?.NombreCompleto,
            local.Propietario?.Email,
            local.Propietario?.Telefono,
            local.EstadoAprobacion,
            local.CertificadoRucUrl,
            local.MotivoRechazo,
            local.FechaRevision,
            local.RevisadoPor?.NombreCompleto,
            calificacionPromedio,
            totalResenas,
            local.CreatedAt
        );
    }
}
