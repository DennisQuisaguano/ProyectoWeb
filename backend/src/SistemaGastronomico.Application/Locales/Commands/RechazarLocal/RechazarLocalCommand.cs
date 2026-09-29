namespace SistemaGastronomico.Application.Locales.Commands.RechazarLocal;

using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Exceptions;
using SistemaGastronomico.Application.Common.Interfaces;
using SistemaGastronomico.Domain.Enums;

public record RechazarLocalCommand(
    Guid LocalId,
    Guid AdminId,
    string Motivo
) : IRequest<LocalDto>;

public class RechazarLocalCommandValidator : AbstractValidator<RechazarLocalCommand>
{
    public RechazarLocalCommandValidator()
    {
        RuleFor(v => v.LocalId).NotEmpty();
        RuleFor(v => v.Motivo)
            .NotEmpty().WithMessage("Es obligatorio ingresar el motivo de rechazo para retroalimentar al comerciante.")
            .MaximumLength(1000).WithMessage("El motivo no debe exceder los 1000 caracteres.");
    }
}

public class RechazarLocalCommandHandler : IRequestHandler<RechazarLocalCommand, LocalDto>
{
    private readonly IApplicationDbContext _context;
    private readonly INotificacionService _notificacionService;

    public RechazarLocalCommandHandler(
        IApplicationDbContext context,
        INotificacionService notificacionService)
    {
        _context = context;
        _notificacionService = notificacionService;
    }

    public async Task<LocalDto> Handle(RechazarLocalCommand request, CancellationToken cancellationToken)
    {
        var local = await _context.Locales
            .Include(l => l.Propietario)
            .FirstOrDefaultAsync(l => l.Id == request.LocalId && l.IsActive, cancellationToken);

        if (local == null)
        {
            throw new NotFoundException("Local", request.LocalId);
        }

        local.EstadoAprobacion = EstadoAprobacionLocal.Rechazado;
        local.EstaAbierto = false;
        local.MotivoRechazo = request.Motivo.Trim();
        local.FechaRevision = DateTime.UtcNow;
        local.RevisadoPorId = request.AdminId;
        local.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);

        // Notificar al dueño por campanita (SignalR)
        if (local.PropietarioId != Guid.Empty)
        {
            await _notificacionService.SendNotificacionAsync(
                local.PropietarioId,
                "error",
                $"Tu solicitud para '{local.Nombre}' fue rechazada. Motivo: {request.Motivo.Trim()}",
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
