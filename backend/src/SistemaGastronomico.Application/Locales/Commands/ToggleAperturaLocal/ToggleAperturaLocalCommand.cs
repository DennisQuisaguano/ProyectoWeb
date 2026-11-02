namespace SistemaGastronomico.Application.Locales.Commands.ToggleAperturaLocal;

using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Exceptions;
using SistemaGastronomico.Application.Common.Interfaces;

public record ToggleAperturaLocalCommand(Guid LocalId) : IRequest<bool>;

public class ToggleAperturaLocalCommandHandler : IRequestHandler<ToggleAperturaLocalCommand, bool>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public ToggleAperturaLocalCommandHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<bool> Handle(ToggleAperturaLocalCommand request, CancellationToken cancellationToken)
    {
        var local = await _context.Locales
            .FirstOrDefaultAsync(l => l.Id == request.LocalId && l.IsActive, cancellationToken);

        if (local == null)
        {
            throw new NotFoundException("Local", request.LocalId);
        }

        _currentUser.EnsureOwnerOrAdmin(local.PropietarioId);

        local.EstaAbierto = !local.EstaAbierto;
        local.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);
        return local.EstaAbierto;
    }
}
