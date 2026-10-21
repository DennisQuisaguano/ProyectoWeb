namespace SistemaGastronomico.Application.Locales.Queries.GetLocalById;

using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Exceptions;
using SistemaGastronomico.Application.Common.Interfaces;

public record GetLocalByIdQuery(Guid Id) : IRequest<LocalDto>;

public class GetLocalByIdQueryHandler : IRequestHandler<GetLocalByIdQuery, LocalDto>
{
    private readonly IApplicationDbContext _context;

    public GetLocalByIdQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<LocalDto> Handle(GetLocalByIdQuery request, CancellationToken cancellationToken)
    {
        var local = await _context.Locales
            .Include(l => l.Propietario)
            .Include(l => l.Resenas)
            .AsNoTracking()
            .FirstOrDefaultAsync(l => l.Id == request.Id && l.IsActive, cancellationToken);

        if (local == null)
        {
            throw new NotFoundException("Local", request.Id);
        }

        var validResenas = local.Resenas.Where(r => r.IsActive).ToList();
        var totalResenas = validResenas.Count;
        var calificacionPromedio = totalResenas > 0
            ? Math.Round(validResenas.Average(r => r.Calificacion), 1)
            : 0.0;

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
            local.Propietario?.Email,
            calificacionPromedio,
            totalResenas
        );
    }
}
