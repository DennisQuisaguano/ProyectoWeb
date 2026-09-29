namespace SistemaGastronomico.Application.Common.Interfaces;

public interface INotificacionService
{
    Task SendNotificacionAsync(Guid usuarioId, string tipo, string mensaje, CancellationToken cancellationToken = default);
    Task NotificarAdminsAsync(string tipo, string mensaje, CancellationToken cancellationToken = default);
}
