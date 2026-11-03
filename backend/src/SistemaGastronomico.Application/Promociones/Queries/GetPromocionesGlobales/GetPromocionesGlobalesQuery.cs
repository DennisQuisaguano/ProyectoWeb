namespace SistemaGastronomico.Application.Promociones.Queries.GetPromocionesGlobales;

using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Interfaces;
using SistemaGastronomico.Application.Promociones;
using SistemaGastronomico.Domain.Enums;

public record GetPromocionesGlobalesQuery(
    CampusUTA? Campus = null,
    bool? SoloActivas = true
) : IRequest<List<PromocionGlobalDto>>;

public class GetPromocionesGlobalesQueryHandler : IRequestHandler<GetPromocionesGlobalesQuery, List<PromocionGlobalDto>>
{
    private readonly IApplicationDbContext _context;

    public GetPromocionesGlobalesQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<PromocionGlobalDto>> Handle(GetPromocionesGlobalesQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Promociones
            .Include(p => p.Local)
            .Include(p => p.Plato)
            .Where(p => p.IsActive && p.Local != null && p.Local.IsActive && p.Local.EstadoAprobacion == EstadoAprobacionLocal.Aprobado)
            .AsNoTracking();

        if (request.Campus.HasValue)
        {
            query = query.Where(p => p.Local!.CampusCercano == request.Campus.Value);
        }

        if (request.SoloActivas.HasValue && request.SoloActivas.Value)
        {
            var now = DateTime.UtcNow;
            query = query.Where(p => p.EstaActiva && p.FechaInicio <= now && p.FechaFin >= now);
        }

        var promociones = await query
            .OrderByDescending(p => p.CreatedAt)
            .Select(p => new PromocionGlobalDto(
                p.Id,
                p.LocalId,
                p.Local!.Nombre,
                p.Local.LogoUrl,
                p.Local.CampusCercano,
                p.PlatoId,
                p.Plato != null ? p.Plato.Nombre : null,
                p.Titulo,
                p.Descripcion,
                p.PrecioOriginal,
                p.PrecioPromocional,
                p.ImagenUrl,
                p.DiasValidos,
                p.FechaInicio,
                p.FechaFin,
                p.EstaActiva
            ))
            .ToListAsync(cancellationToken);

        // Las promociones con días específicos solo se muestran el día que aplican.
        if (request.SoloActivas == true)
        {
            var ahora = DateTime.UtcNow;
            promociones = promociones.Where(p => PromocionDias.AplicaHoy(p.DiasValidos, ahora)).ToList();
        }

        return promociones;
    }
}
