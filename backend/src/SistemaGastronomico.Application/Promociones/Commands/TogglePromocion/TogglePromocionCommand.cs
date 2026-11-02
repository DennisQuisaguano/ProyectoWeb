namespace SistemaGastronomico.Application.Promociones.Commands.TogglePromocion;

using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Exceptions;
using SistemaGastronomico.Application.Common.Interfaces;

public record TogglePromocionCommand(Guid PromocionId) : IRequest<bool>;

public class TogglePromocionCommandHandler : IRequestHandler<TogglePromocionCommand, bool>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public TogglePromocionCommandHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<bool> Handle(TogglePromocionCommand request, CancellationToken cancellationToken)
    {
        var promo = await _context.Promociones
            .Include(p => p.Local)
            .FirstOrDefaultAsync(p => p.Id == request.PromocionId && p.IsActive, cancellationToken);

        if (promo == null)
        {
            throw new NotFoundException("Promocion", request.PromocionId);
        }

        _currentUser.EnsureOwnerOrAdmin(promo.Local.PropietarioId);

        promo.EstaActiva = !promo.EstaActiva;

        if (promo.EstaActiva)
        {
            var now = DateTime.UtcNow;
            if (promo.FechaFin < now)
            {
                var duration = promo.FechaFin - promo.FechaInicio;
                if (duration.TotalDays < 1) duration = TimeSpan.FromDays(7);
                promo.FechaInicio = now;
                promo.FechaFin = now.Add(duration);
            }
        }

        promo.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);
        return promo.EstaActiva;
    }
}
