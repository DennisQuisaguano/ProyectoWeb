using MediatR;
using Microsoft.EntityFrameworkCore;
using SistemaGastronomico.Application.Common.Exceptions;
using SistemaGastronomico.Application.Common.Interfaces;

namespace SistemaGastronomico.Application.Usuarios.Commands.RequestManualPasswordReset;

public record RequestManualPasswordResetCommand(string Email, string Telefono, string NewPassword) : IRequest<bool>;

public class RequestManualPasswordResetCommandHandler : IRequestHandler<RequestManualPasswordResetCommand, bool>
{
    private readonly IApplicationDbContext _context;
    private readonly IPasswordHasher _passwordHasher;
    private readonly INotificacionService _notificacionService;

    public RequestManualPasswordResetCommandHandler(
        IApplicationDbContext context, 
        IPasswordHasher passwordHasher,
        INotificacionService notificacionService)
    {
        _context = context;
        _passwordHasher = passwordHasher;
        _notificacionService = notificacionService;
    }

    public async Task<bool> Handle(RequestManualPasswordResetCommand request, CancellationToken cancellationToken)
    {
        var user = await _context.Usuarios
            .FirstOrDefaultAsync(u => u.Email == request.Email, cancellationToken);

        if (user == null || user.Telefono != request.Telefono)
        {
            throw new System.Exception("Datos inválidos o el usuario no existe.");
        }

        user.PendingPasswordHash = _passwordHasher.HashPassword(request.NewPassword);
        user.IsPasswordResetPending = true;
        user.PasswordResetRequestedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);

        await _notificacionService.NotificarAdminsAsync(
            "Nueva solicitud de restablecimiento de contraseña",
            $"El usuario {user.Email} ha solicitado un restablecimiento de contraseña."
        );

        return true;
    }
}
