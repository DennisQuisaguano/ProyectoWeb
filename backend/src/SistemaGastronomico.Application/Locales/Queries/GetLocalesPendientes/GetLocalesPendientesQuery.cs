namespace SistemaGastronomico.Application.Locales.Queries.GetLocalesPendientes;

using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Interfaces;
using SistemaGastronomico.Domain.Enums;

public record GetLocalesPendientesQuery(EstadoAprobacionLocal? Estado = EstadoAprobacionLocal.Pendiente) : IRequest<List<LocalDto>>;

public class GetLocalesPendientesQueryHandler : IRequestHandler<GetLocalesPendientesQuery, List<LocalDto>>
{
    private readonly IApplicationDbContext _context;

    public GetLocalesPendientesQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<LocalDto>> Handle(GetLocalesPendientesQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Locales
            .Include(l => l.Propietario)
            .Where(l => l.IsActive);

        if (request.Estado.HasValue)
        {
            query = query.Where(l => l.EstadoAprobacion == request.Estado.Value);
        }

        var locales = await query
            .OrderByDescending(l => l.CreatedAt)
            .ToListAsync(cancellationToken);

        return locales.Select(local => new LocalDto(
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
        )).ToList();
    }
}
