namespace src.Services;

using System.Net.Http.Json;
using src.Models;

public class AdminService
{
    private readonly HttpClient _http;

    public AdminService(HttpClient http)
    {
        _http = http;
    }

    public async Task<AdminMetricsModel?> GetMetricsAsync()
    {
        try
        {
            return await _http.GetFromJsonAsync<AdminMetricsModel>("api/admin/metrics");
        }
        catch
        {
            return null;
        }
    }

    public async Task<List<LocalAdminModel>> GetLocalesAsync(
        CampusUTAModel? campus = null,
        CategoriaLocalModel? categoria = null,
        EstadoAprobacionLocalModel? estado = null,
        bool? soloBajaCalificacion = null,
        bool? soloDeshabilitados = null,
        string? search = null,
        string? orderBy = null)
    {
        try
        {
            var query = new List<string>();
            if (campus.HasValue) query.Add($"campus={(int)campus.Value}");
            if (categoria.HasValue) query.Add($"categoria={(int)categoria.Value}");
            if (estado.HasValue) query.Add($"estadoAprobacion={(int)estado.Value}");
            if (soloBajaCalificacion.HasValue) query.Add($"soloBajaCalificacion={soloBajaCalificacion.Value}");
            if (soloDeshabilitados.HasValue) query.Add($"soloDeshabilitados={soloDeshabilitados.Value}");
            if (!string.IsNullOrWhiteSpace(search)) query.Add($"search={Uri.EscapeDataString(search)}");
            if (!string.IsNullOrWhiteSpace(orderBy)) query.Add($"orderBy={Uri.EscapeDataString(orderBy)}");

            var url = "api/admin/locales" + (query.Count > 0 ? "?" + string.Join("&", query) : "");
            return await _http.GetFromJsonAsync<List<LocalAdminModel>>(url) ?? new List<LocalAdminModel>();
        }
        catch
        {
            return new List<LocalAdminModel>();
        }
    }

    public async Task<(bool Exito, LocalAdminModel? Local, string? Error)> ToggleOperativoAsync(
        Guid localId,
        bool habilitar,
        string? motivo = null)
    {
        try
        {
            var response = await _http.PostAsJsonAsync($"api/admin/locales/{localId}/toggle-operativo", new
            {
                Habilitar = habilitar,
                Motivo = motivo
            });

            if (response.IsSuccessStatusCode)
            {
                var local = await response.Content.ReadFromJsonAsync<LocalAdminModel>();
                return (true, local, null);
            }

            var err = await response.Content.ReadAsStringAsync();
            return (false, null, string.IsNullOrWhiteSpace(err) ? "Error al cambiar el estado operativo." : err);
        }
        catch (Exception ex)
        {
            return (false, null, ex.Message);
        }
    }

    public async Task<List<ResenaDetalleModel>> GetResenasAsync(Guid localId)
    {
        try
        {
            return await _http.GetFromJsonAsync<List<ResenaDetalleModel>>($"api/admin/locales/{localId}/resenas") 
                   ?? new List<ResenaDetalleModel>();
        }
        catch
        {
            return new List<ResenaDetalleModel>();
        }
    }

    public async Task<List<PendingPasswordResetModel>> GetPendingPasswordResetsAsync()
    {
        try
        {
            return await _http.GetFromJsonAsync<List<PendingPasswordResetModel>>("api/admin/claves-pendientes") 
                   ?? new List<PendingPasswordResetModel>();
        }
        catch
        {
            return new List<PendingPasswordResetModel>();
        }
    }

    public async Task<bool> ApprovePasswordResetAsync(Guid id)
    {
        var response = await _http.PostAsync($"api/admin/claves/{id}/aprobar", null);
        return response.IsSuccessStatusCode;
    }

    public async Task<bool> RejectPasswordResetAsync(Guid id)
    {
        var response = await _http.PostAsync($"api/admin/claves/{id}/rechazar", null);
        return response.IsSuccessStatusCode;
    }
}
