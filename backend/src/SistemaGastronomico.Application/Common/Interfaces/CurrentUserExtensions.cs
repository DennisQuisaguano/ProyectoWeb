namespace SistemaGastronomico.Application.Common.Interfaces;

using SistemaGastronomico.Application.Common.Exceptions;

public static class CurrentUserExtensions
{
    /// <summary>
    /// Permite la acción solo al administrador o al propietario del local.
    /// </summary>
    public static void EnsureOwnerOrAdmin(this ICurrentUserService currentUser, Guid propietarioId)
    {
        if (currentUser.IsAdmin)
        {
            return;
        }

        if (currentUser.UserId is null || currentUser.UserId.Value != propietarioId)
        {
            throw new ForbiddenAccessException();
        }
    }
}
