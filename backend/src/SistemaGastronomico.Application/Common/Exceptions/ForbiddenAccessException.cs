namespace SistemaGastronomico.Application.Common.Exceptions;

public class ForbiddenAccessException : Exception
{
    public ForbiddenAccessException()
        : base("No tienes permisos para realizar esta acción sobre este recurso.")
    {
    }
}
