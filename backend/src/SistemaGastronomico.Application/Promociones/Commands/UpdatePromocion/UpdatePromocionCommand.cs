namespace SistemaGastronomico.Application.Promociones.Commands.UpdatePromocion;

using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Exceptions;
using SistemaGastronomico.Application.Common.Interfaces;

public record UpdatePromocionCommand(
    Guid Id,
    Guid LocalId,
    string Titulo,
    string Descripcion,
    decimal? PrecioOriginal,
    decimal PrecioPromocional,
    string? ImagenUrl,
    string? DiasValidos,
    Guid? PlatoId,
    DateTime FechaInicio,
    DateTime FechaFin
) : IRequest<PromocionDto>;

public class UpdatePromocionCommandHandler : IRequestHandler<UpdatePromocionCommand, PromocionDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;
    private readonly INotificacionService _notificacionService;

    public UpdatePromocionCommandHandler(IApplicationDbContext context, INotificacionService notificacionService, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
        _notificacionService = notificacionService;
    }

    public async Task<PromocionDto> Handle(UpdatePromocionCommand request, CancellationToken cancellationToken)
    {
        var promocion = await _context.Promociones
            .Include(p => p.Local)
            .FirstOrDefaultAsync(p => p.Id == request.Id && p.LocalId == request.LocalId, cancellationToken);

        if (promocion == null)
        {
            throw new NotFoundException("Promocion", request.Id);
        }

        _currentUser.EnsureOwnerOrAdmin(promocion.Local.PropietarioId);

        var oldFechaInicio = promocion.FechaInicio;
        var oldDiasValidos = promocion.DiasValidos;
        var oldPrecio = promocion.PrecioPromocional;

        promocion.Titulo = request.Titulo;
        promocion.Descripcion = request.Descripcion;
        promocion.PrecioOriginal = request.PrecioOriginal;
        promocion.PrecioPromocional = request.PrecioPromocional;
        promocion.ImagenUrl = request.ImagenUrl;
        promocion.DiasValidos = request.DiasValidos;
        promocion.PlatoId = request.PlatoId;
        promocion.FechaInicio = request.FechaInicio.ToUniversalTime();
        promocion.FechaFin = request.FechaFin.ToUniversalTime();
        promocion.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);

        // Notificar a los estudiantes si la oferta se actualizó (cambio de fecha, día o precio)
        try
        {
            if (PromocionDias.AplicaHoy(promocion.DiasValidos, DateTime.UtcNow))
            {
                var nombreLocal = promocion.Local?.Nombre ?? "un local de la UTA";
                var precioTexto = $"${promocion.PrecioPromocional:F2}";
                var mensaje = $"¡Oferta actualizada en {nombreLocal}! {promocion.Titulo} por {precioTexto}. Válida ahora.";
                await _notificacionService.NotificarEstudiantesAsync("promocion", mensaje, cancellationToken);
            }
        }
        catch
        {
            // La notificación no bloquea la actualización
        }

        return new PromocionDto(
            promocion.Id,
            promocion.LocalId,
            promocion.PlatoId,
            promocion.Titulo,
            promocion.Descripcion,
            promocion.PrecioOriginal,
            promocion.PrecioPromocional,
            promocion.ImagenUrl,
            promocion.DiasValidos,
            promocion.FechaInicio,
            promocion.FechaFin,
            promocion.EstaActiva
        );
    }
}
