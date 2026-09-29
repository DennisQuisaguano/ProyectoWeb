using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Exceptions;
using SistemaGastronomico.Application.Common.Interfaces;

namespace SistemaGastronomico.Application.Usuarios.Commands.RejectPasswordReset;

public record RejectPasswordResetCommand(Guid UserId) : IRequest<bool>;

public class RejectPasswordResetCommandHandler : IRequestHandler<RejectPasswordResetCommand, bool>
{
    private readonly IApplicationDbContext _context;

    public RejectPasswordResetCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<bool> Handle(RejectPasswordResetCommand request, CancellationToken cancellationToken)
    {
        var user = await _context.Usuarios
            .FirstOrDefaultAsync(u => u.Id == request.UserId, cancellationToken);

        if (user == null)
            throw new NotFoundException("Usuario no encontrado.");

        if (!user.IsPasswordResetPending)
            throw new System.Exception("El usuario no tiene un restablecimiento de contraseña pendiente.");

        user.PendingPasswordHash = null;
        user.IsPasswordResetPending = false;
        user.PasswordResetRequestedAt = null;

        await _context.SaveChangesAsync(cancellationToken);

        return true;
    }
}
