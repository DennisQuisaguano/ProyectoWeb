namespace SistemaGastronomico.Application.Menus.Commands.ToggleDisponibilidadPlato;

using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Exceptions;
using SistemaGastronomico.Application.Common.Interfaces;

public record ToggleDisponibilidadPlatoCommand(Guid PlatoId) : IRequest<bool>;

public class ToggleDisponibilidadPlatoCommandHandler : IRequestHandler<ToggleDisponibilidadPlatoCommand, bool>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public ToggleDisponibilidadPlatoCommandHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<bool> Handle(ToggleDisponibilidadPlatoCommand request, CancellationToken cancellationToken)
    {
        var plato = await _context.Platos
            .Include(p => p.Local)
            .FirstOrDefaultAsync(p => p.Id == request.PlatoId && p.IsActive, cancellationToken);

        if (plato == null)
        {
            throw new NotFoundException("Plato", request.PlatoId);
        }

        _currentUser.EnsureOwnerOrAdmin(plato.Local.PropietarioId);

        plato.EstaDisponible = !plato.EstaDisponible;
        plato.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);
        return plato.EstaDisponible;
    }
}
