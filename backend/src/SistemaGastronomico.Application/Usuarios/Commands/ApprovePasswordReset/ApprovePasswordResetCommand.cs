using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Exceptions;
using SistemaGastronomico.Application.Common.Interfaces;

namespace SistemaGastronomico.Application.Usuarios.Commands.ApprovePasswordReset;

public record ApprovePasswordResetCommand(Guid UserId) : IRequest<bool>;

public class ApprovePasswordResetCommandHandler : IRequestHandler<ApprovePasswordResetCommand, bool>
{
    private readonly IApplicationDbContext _context;

    public ApprovePasswordResetCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<bool> Handle(ApprovePasswordResetCommand request, CancellationToken cancellationToken)
    {
        var user = await _context.Usuarios
            .FirstOrDefaultAsync(u => u.Id == request.UserId, cancellationToken);

        if (user == null)
            throw new NotFoundException("Usuario no encontrado.");

        if (!user.IsPasswordResetPending || string.IsNullOrEmpty(user.PendingPasswordHash))
            throw new System.Exception("El usuario no tiene un restablecimiento de contraseña pendiente.");

        user.PasswordHash = user.PendingPasswordHash;
        
        user.PendingPasswordHash = null;
        user.IsPasswordResetPending = false;
        user.PasswordResetRequestedAt = null;

        await _context.SaveChangesAsync(cancellationToken);

        return true;
    }
}
