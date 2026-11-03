namespace SistemaGastronomico.Application.Menus;

using SistemaGastronomico.Application.Common.Interfaces;

/// <summary>
/// Avisa a los estudiantes cuando un local publica un plato del día.
/// </summary>
public static class PlatoDelDiaNotificador
{
    public const string Tipo = "plato_del_dia";

    public static async Task NotificarAsync(
        INotificacionService notificacionService,
        string? localNombre,
        string platoNombre,
        decimal precio,
        CancellationToken cancellationToken)
    {
        try
        {
            var local = string.IsNullOrWhiteSpace(localNombre) ? "un local de la UTA" : localNombre;
            var mensaje = $"⭐ Plato del día en {local}: {platoNombre} por ${precio:F2}.";
            await notificacionService.NotificarEstudiantesAsync(Tipo, mensaje, cancellationToken);
        }
        catch
        {
            // La notificación no debe bloquear la operación sobre el plato
        }
    }
}
