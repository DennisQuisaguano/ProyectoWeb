namespace SistemaGastronomico.Application.Admin.Queries.GetLocalesAdmin;

using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Admin;
using SistemaGastronomico.Application.Common.Interfaces;
using SistemaGastronomico.Domain.Enums;

public record GetLocalesAdminQuery(
    CampusUTA? Campus = null,
    CategoriaLocal? Categoria = null,
    EstadoAprobacionLocal? EstadoAprobacion = null,
    bool? SoloBajaCalificacion = null,
    bool? SoloDeshabilitados = null,
    string? Search = null,
    string? OrderBy = null
) : IRequest<List<LocalAdminDto>>;

public class GetLocalesAdminQueryHandler : IRequestHandler<GetLocalesAdminQuery, List<LocalAdminDto>>
{
    private readonly IApplicationDbContext _context;

    public GetLocalesAdminQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<LocalAdminDto>> Handle(GetLocalesAdminQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Locales
            .AsNoTracking()
            .Include(l => l.Propietario)
            .Include(l => l.RevisadoPor)
            .Include(l => l.Resenas)
            .AsQueryable();

        if (request.Campus.HasValue)
        {
            query = query.Where(l => l.CampusCercano == request.Campus.Value);
        }

        if (request.Categoria.HasValue)
        {
            query = query.Where(l => l.Categoria == request.Categoria.Value);
        }

        if (request.EstadoAprobacion.HasValue)
        {
            query = query.Where(l => l.EstadoAprobacion == request.EstadoAprobacion.Value);
        }

        if (request.SoloDeshabilitados.HasValue)
        {
            if (request.SoloDeshabilitados.Value)
            {
                query = query.Where(l => !l.IsActive || !l.EstaAbierto);
            }
            else
            {
                query = query.Where(l => l.IsActive && l.EstaAbierto);
            }
        }

        if (!string.IsNullOrWhiteSpace(request.Search))
        {
            var searchLower = request.Search.ToLower().Trim();
            query = query.Where(l =>
                l.Nombre.ToLower().Contains(searchLower) ||
                l.Direccion.ToLower().Contains(searchLower) ||
                (l.Propietario != null && (
                    l.Propietario.NombreCompleto.ToLower().Contains(searchLower) ||
                    l.Propietario.Email.ToLower().Contains(searchLower)
                ))
            );
        }

        var localesList = await query.ToListAsync(cancellationToken);

        // Mapear a DTO con cálculo en memoria de reseñas
        var dtos = localesList.Select(l =>
        {
            var validResenas = l.Resenas.Where(r => r.IsActive).ToList();
            var totalResenas = validResenas.Count;
            var calificacionPromedio = totalResenas > 0
                ? Math.Round(validResenas.Average(r => r.Calificacion), 1)
                : 0.0;

            return new LocalAdminDto(
                l.Id,
                l.Nombre,
                l.Descripcion,
                l.Direccion,
                l.Referencia,
                l.CampusCercano,
                l.Categoria,
                l.EstaAbierto,
                l.IsActive,
                l.Latitud,
                l.Longitud,
                l.TelefonoContacto,
                l.WhatsApp,
                l.HorarioApertura,
                l.LogoUrl,
                l.PortadaUrl,
                l.PropietarioId,
                l.Propietario?.NombreCompleto,
                l.Propietario?.Email,
                l.Propietario?.Telefono,
                l.EstadoAprobacion,
                l.CertificadoRucUrl,
                l.MotivoRechazo,
                l.FechaRevision,
                l.RevisadoPor?.NombreCompleto,
                calificacionPromedio,
                totalResenas,
                l.CreatedAt
            );
        }).ToList();

        // Filtro adicional por baja calificación (< 3.0 con al menos 1 reseña)
        if (request.SoloBajaCalificacion == true)
        {
            dtos = dtos.Where(d => d.TotalResenas > 0 && d.CalificacionPromedio < 3.0).ToList();
        }

        // Ordenamiento
        var order = request.OrderBy?.ToLower().Trim();
        dtos = order switch
        {
            "estrellas_asc" => dtos.OrderBy(d => d.TotalResenas == 0 ? 99 : d.CalificacionPromedio).ThenBy(d => d.Nombre).ToList(),
            "estrellas_desc" => dtos.OrderByDescending(d => d.CalificacionPromedio).ThenByDescending(d => d.TotalResenas).ToList(),
            "nombre_asc" => dtos.OrderBy(d => d.Nombre).ToList(),
            "pendientes_primero" => dtos.OrderBy(d => d.EstadoAprobacion == EstadoAprobacionLocal.Pendiente ? 0 : 1).ThenByDescending(d => d.CreatedAt).ToList(),
            _ => dtos.OrderByDescending(d => d.CreatedAt).ToList()
        };

        return dtos;
    }
}
