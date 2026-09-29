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

    public UpdatePromocionCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<PromocionDto> Handle(UpdatePromocionCommand request, CancellationToken cancellationToken)
    {
        var promocion = await _context.Promociones
            .FirstOrDefaultAsync(p => p.Id == request.Id && p.LocalId == request.LocalId, cancellationToken);

        if (promocion == null)
        {
            throw new NotFoundException("Promocion", request.Id);
        }

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
