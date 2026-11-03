namespace SistemaGastronomico.Application.Promociones;

using System.Globalization;
using System.Text;

/// <summary>
/// Reglas de los días de la semana en que aplica una promoción.
/// </summary>
public static class PromocionDias
{
    // Ecuador (UTA) no usa horario de verano: UTC-5 todo el año.
    private static readonly TimeSpan OffsetEcuador = TimeSpan.FromHours(-5);

    /// <summary>
    /// Indica si la promoción aplica en el día de la semana de <paramref name="utcAhora"/> (hora de Ecuador).
    /// Sin días configurados significa "todos los días".
    /// </summary>
    public static bool AplicaHoy(string? diasValidos, DateTime utcAhora)
    {
        if (string.IsNullOrWhiteSpace(diasValidos))
        {
            return true;
        }

        var hoy = Normalizar(NombreDia((utcAhora + OffsetEcuador).DayOfWeek));

        return diasValidos
            .Split(',', StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries)
            .Select(Normalizar)
            .Contains(hoy);
    }

    private static string NombreDia(DayOfWeek dia) => dia switch
    {
        DayOfWeek.Monday => "Lunes",
        DayOfWeek.Tuesday => "Martes",
        DayOfWeek.Wednesday => "Miércoles",
        DayOfWeek.Thursday => "Jueves",
        DayOfWeek.Friday => "Viernes",
        DayOfWeek.Saturday => "Sábado",
        _ => "Domingo"
    };

    private static string Normalizar(string texto)
    {
        var descompuesto = texto.Trim().Normalize(NormalizationForm.FormD);
        var sb = new StringBuilder(descompuesto.Length);
        foreach (var c in descompuesto)
        {
            if (CharUnicodeInfo.GetUnicodeCategory(c) != UnicodeCategory.NonSpacingMark)
            {
                sb.Append(c);
            }
        }

        return sb.ToString().ToLowerInvariant();
    }
}
