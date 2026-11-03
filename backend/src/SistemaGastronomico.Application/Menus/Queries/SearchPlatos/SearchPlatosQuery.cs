namespace SistemaGastronomico.Application.Menus.Queries.SearchPlatos;

using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Interfaces;
using SistemaGastronomico.Application.Menus;
using SistemaGastronomico.Domain.Enums;

public record SearchPlatosQuery(
    string? Search = null,
    CampusUTA? Campus = null,
    CategoriaPlato? Categoria = null,
    bool? SoloDisponibles = true,
    decimal? PrecioMaximo = null,
    bool? SoloPlatoDelDia = null
) : IRequest<List<PlatoBusquedaDto>>;

public class SearchPlatosQueryHandler : IRequestHandler<SearchPlatosQuery, List<PlatoBusquedaDto>>
{
    private readonly IApplicationDbContext _context;

    public SearchPlatosQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<PlatoBusquedaDto>> Handle(SearchPlatosQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Platos
            .Include(p => p.Local)
            .Where(p => p.IsActive && p.Local != null && p.Local.IsActive && p.Local.EstadoAprobacion == EstadoAprobacionLocal.Aprobado)
            .AsNoTracking();

        if (request.Campus.HasValue)
        {
            query = query.Where(p => p.Local!.CampusCercano == request.Campus.Value);
        }

        if (request.Categoria.HasValue)
        {
            query = query.Where(p => p.Categoria == request.Categoria.Value);
        }

        if (request.SoloDisponibles.HasValue && request.SoloDisponibles.Value)
        {
            query = query.Where(p => p.EstaDisponible);
        }

        if (request.SoloPlatoDelDia == true)
        {
            query = query.Where(p => p.EsPlatoDelDia);
        }

        if (request.PrecioMaximo.HasValue)
        {
            query = query.Where(p => p.Precio <= request.PrecioMaximo.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.Search))
        {
            var searchLower = request.Search.ToLower().Trim();
            query = query.Where(p =>
                p.Nombre.ToLower().Contains(searchLower) ||
                p.Descripcion.ToLower().Contains(searchLower) ||
                p.Local!.Nombre.ToLower().Contains(searchLower)
            );
        }

        var platos = await query
            .OrderBy(p => p.Precio)
            .Select(p => new PlatoBusquedaDto(
                p.Id,
                p.LocalId,
                p.Local!.Nombre,
                p.Local.CampusCercano,
                p.Nombre,
                p.Descripcion,
                p.Categoria.ToString(),
                p.Categoria,
                p.Precio,
                p.ImagenUrl,
                p.EstaDisponible,
                p.EsPlatoDelDia
            ))
            .ToListAsync(cancellationToken);

        return platos;
    }
}
