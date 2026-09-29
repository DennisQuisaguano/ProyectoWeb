namespace SistemaGastronomico.Application.Admin.Queries.GetResenasByLocal;

using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Admin;
using SistemaGastronomico.Application.Common.Interfaces;

public record GetResenasByLocalQuery(Guid LocalId) : IRequest<List<ResenaDetalleDto>>;

public class GetResenasByLocalQueryHandler : IRequestHandler<GetResenasByLocalQuery, List<ResenaDetalleDto>>
{
    private readonly IApplicationDbContext _context;

    public GetResenasByLocalQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<ResenaDetalleDto>> Handle(GetResenasByLocalQuery request, CancellationToken cancellationToken)
    {
        var resenas = await _context.Resenas
            .AsNoTracking()
            .Include(r => r.Local)
            .Include(r => r.Estudiante)
            .Where(r => r.LocalId == request.LocalId && r.IsActive)
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
