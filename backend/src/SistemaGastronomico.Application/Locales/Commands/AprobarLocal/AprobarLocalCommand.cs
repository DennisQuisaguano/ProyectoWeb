namespace SistemaGastronomico.Application.Locales.Commands.AprobarLocal;

using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Exceptions;
using SistemaGastronomico.Application.Common.Interfaces;
using SistemaGastronomico.Domain.Enums;

public record AprobarLocalCommand(
    Guid LocalId,
    Guid AdminId
) : IRequest<LocalDto>;

public class AprobarLocalCommandHandler : IRequestHandler<AprobarLocalCommand, LocalDto>
{
    private readonly IApplicationDbContext _context;
    private readonly INotificacionService _notificacionService;

    public AprobarLocalCommandHandler(
        IApplicationDbContext context,
        INotificacionService notificacionService)
    {
        _context = context;
        _notificacionService = notificacionService;
    }

    public async Task<LocalDto> Handle(AprobarLocalCommand request, CancellationToken cancellationToken)
    {
        var local = await _context.Locales
            .Include(l => l.Propietario)
            .FirstOrDefaultAsync(l => l.Id == request.LocalId && l.IsActive, cancellationToken);

        if (local == null)
        {
            throw new NotFoundException("Local", request.LocalId);
        }

        local.EstadoAprobacion = EstadoAprobacionLocal.Aprobado;
        local.EstaAbierto = true;
        local.FechaRevision = DateTime.UtcNow;
        local.RevisadoPorId = request.AdminId;
        local.MotivoRechazo = null;
        local.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);

        // Notificar al dueño por campanita (SignalR)
        if (local.PropietarioId != Guid.Empty)
        {
            await _notificacionService.SendNotificacionAsync(
                local.PropietarioId,
                "success",
                $"¡Tu local '{local.Nombre}' fue aprobado! Ya está activo y visible para los estudiantes.",
                cancellationToken
            );
        }

        return new LocalDto(
            local.Id,
            local.Nombre,
            local.Descripcion,
            local.Direccion,
            local.Referencia,
            local.CampusCercano,
            local.Categoria,
            local.EstaAbierto,
            local.Latitud,
            local.Longitud,
            local.TelefonoContacto,
            local.WhatsApp,
            local.HorarioApertura,
            local.LogoUrl,
            local.PortadaUrl,
            local.PropietarioId,
            local.Propietario?.NombreCompleto,
            local.EstadoAprobacion,
            local.CertificadoRucUrl,
            local.MotivoRechazo,
            local.Propietario?.Email
        );
    }
}
