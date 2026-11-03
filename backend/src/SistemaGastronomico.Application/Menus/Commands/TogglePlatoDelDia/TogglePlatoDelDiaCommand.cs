namespace SistemaGastronomico.Application.Menus.Commands.TogglePlatoDelDia;

using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Exceptions;
using SistemaGastronomico.Application.Common.Interfaces;

public record TogglePlatoDelDiaCommand(Guid PlatoId) : IRequest<bool>;

public class TogglePlatoDelDiaCommandHandler : IRequestHandler<TogglePlatoDelDiaCommand, bool>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;
    private readonly INotificacionService _notificacionService;

    public TogglePlatoDelDiaCommandHandler(IApplicationDbContext context, ICurrentUserService currentUser, INotificacionService notificacionService)
    {
        _context = context;
        _currentUser = currentUser;
        _notificacionService = notificacionService;
    }

    public async Task<bool> Handle(TogglePlatoDelDiaCommand request, CancellationToken cancellationToken)
    {
        var plato = await _context.Platos
            .Include(p => p.Local)
            .FirstOrDefaultAsync(p => p.Id == request.PlatoId && p.IsActive, cancellationToken);

        if (plato == null)
        {
            throw new NotFoundException("Plato", request.PlatoId);
        }

        _currentUser.EnsureOwnerOrAdmin(plato.Local.PropietarioId);

        plato.EsPlatoDelDia = !plato.EsPlatoDelDia;
        plato.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);

        if (plato.EsPlatoDelDia)
        {
            await PlatoDelDiaNotificador.NotificarAsync(
                _notificacionService, plato.Local.Nombre, plato.Nombre, plato.Precio, cancellationToken);
        }

        return plato.EsPlatoDelDia;
    }
}
