namespace SistemaGastronomico.Application.Admin.Queries.GetAdminMetrics;

using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Admin;
using SistemaGastronomico.Application.Common.Interfaces;
using SistemaGastronomico.Domain.Enums;

public record GetAdminMetricsQuery : IRequest<AdminDashboardMetricsDto>;

public class GetAdminMetricsQueryHandler : IRequestHandler<GetAdminMetricsQuery, AdminDashboardMetricsDto>
{
    private readonly IApplicationDbContext _context;

    public GetAdminMetricsQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<AdminDashboardMetricsDto> Handle(GetAdminMetricsQuery request, CancellationToken cancellationToken)
    {
        var locales = await _context.Locales
            .AsNoTracking()
            .Include(l => l.Resenas)
            .ToListAsync(cancellationToken);

        var totalLocales = locales.Count;
        var localesAprobados = locales.Count(l => l.EstadoAprobacion == EstadoAprobacionLocal.Aprobado);
        var localesPendientes = locales.Count(l => l.EstadoAprobacion == EstadoAprobacionLocal.Pendiente);
        var localesRechazados = locales.Count(l => l.EstadoAprobacion == EstadoAprobacionLocal.Rechazado);
        var localesOperativos = locales.Count(l => l.IsActive && l.EstaAbierto && l.EstadoAprobacion == EstadoAprobacionLocal.Aprobado);
        var localesDeshabilitados = locales.Count(l => !l.IsActive || !l.EstaAbierto);

        // Locales con reseñas y promedio menor a 3.0
        var localesEnRiesgo = locales.Count(l =>
        {
            var validResenas = l.Resenas.Where(r => r.IsActive).ToList();
            return validResenas.Count > 0 && validResenas.Average(r => r.Calificacion) < 3.0;
        });

        var allResenas = await _context.Resenas
            .AsNoTracking()
            .Where(r => r.IsActive)
            .Select(r => r.Calificacion)
            .ToListAsync(cancellationToken);

        var totalResenasGlobal = allResenas.Count;
        var calificacionPromedioGlobal = totalResenasGlobal > 0 ? Math.Round(allResenas.Average(), 1) : 0.0;

        var totalUsuarios = await _context.Usuarios.CountAsync(cancellationToken);
        var totalComerciantes = await _context.Usuarios.CountAsync(u => u.Rol == RolUsuario.DuenoLocal, cancellationToken);
        var totalEstudiantes = await _context.Usuarios.CountAsync(u => u.Rol == RolUsuario.Estudiante, cancellationToken);

        return new AdminDashboardMetricsDto(
            totalLocales,
            localesAprobados,
            localesPendientes,
            localesRechazados,
            localesOperativos,
            localesDeshabilitados,
            localesEnRiesgo,
            calificacionPromedioGlobal,
            totalResenasGlobal,
            totalUsuarios,
            totalComerciantes,
            totalEstudiantes
        );
    }
}
