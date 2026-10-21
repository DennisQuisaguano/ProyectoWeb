namespace SistemaGastronomico.Application.Locales.Queries.GetResenasByPropietario;

using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Admin;
using SistemaGastronomico.Application.Common.Interfaces;

public record GetResenasByPropietarioQuery(Guid PropietarioId) : IRequest<List<ResenaDetalleDto>>;

public class GetResenasByPropietarioQueryHandler : IRequestHandler<GetResenasByPropietarioQuery, List<ResenaDetalleDto>>
{
    private readonly IApplicationDbContext _context;

    public GetResenasByPropietarioQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<ResenaDetalleDto>> Handle(GetResenasByPropietarioQuery request, CancellationToken cancellationToken)
    {
        var resenas = await _context.Resenas
            .AsNoTracking()
            .Include(r => r.Local)
            .Include(r => r.Estudiante)
            .Where(r => r.Local != null && r.Local.PropietarioId == request.PropietarioId && r.IsActive)
            .OrderByDescending(r => r.Fecha)
            .ToListAsync(cancellationToken);

        return resenas.Select(r => new ResenaDetalleDto(
            r.Id,
            r.LocalId,
            r.Local?.Nombre ?? "Local desconocido",
            r.EstudianteId,
            r.Estudiante?.NombreCompleto ?? "Estudiante anónimo",
            r.Estudiante?.Email,
            r.Calificacion,
            r.Comentario,
            r.Fecha
        )).ToList();
    }
}
