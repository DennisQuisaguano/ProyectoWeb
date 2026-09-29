namespace src.Services;

using System.Net.Http.Json;
using src.Models;

public class LocalService
{
    private readonly HttpClient _httpClient;

    public LocalService(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<List<LocalModel>> GetMisLocalesAsync()
    {
        try
        {
            var result = await _httpClient.GetFromJsonAsync<List<LocalModel>>("api/locales/mis-locales");
            return result ?? new List<LocalModel>();
        }
        catch
        {
            return new List<LocalModel>();
        }
    }

    public async Task<LocalModel?> GetByIdAsync(Guid id)
    {
        try
        {
            return await _httpClient.GetFromJsonAsync<LocalModel>($"api/locales/{id}");
        }
        catch
        {
            return null;
        }
    }

    public async Task<(bool Exito, LocalModel? Datos, string? Mensaje)> CreateAsync(CreateOrUpdateLocalModel model)
    {
        try
        {
            var response = await _httpClient.PostAsJsonAsync("api/locales", model);
            if (response.IsSuccessStatusCode)
            {
                var created = await response.Content.ReadFromJsonAsync<LocalModel>();
                return (true, created, null);
            }

            var err = await response.Content.ReadAsStringAsync();
            return (false, null, "Error al crear el local.");
        }
        catch (Exception ex)
        {
            return (false, null, ex.Message);
        }
    }

    public async Task<(bool Exito, LocalModel? Datos, string? Mensaje)> UpdateAsync(CreateOrUpdateLocalModel model)
    {
        try
        {
            var response = await _httpClient.PutAsJsonAsync($"api/locales/{model.Id}", model);
            if (response.IsSuccessStatusCode)
            {
                var updated = await response.Content.ReadFromJsonAsync<LocalModel>();
                return (true, updated, null);
            }

            var err = await response.Content.ReadAsStringAsync();
            return (false, null, "Error al actualizar el local.");
        }
        catch (Exception ex)
        {
            return (false, null, ex.Message);
        }
    }

    public async Task<bool> ToggleAperturaAsync(Guid id)
    {
        try
        {
            var response = await _httpClient.PatchAsync($"api/locales/{id}/toggle-apertura", null);
            return response.IsSuccessStatusCode;
        }
        catch
        {
            return false;
        }
    }

    public async Task<(bool Exito, string? Url, string? Mensaje)> SubirRucAsync(Stream stream, string fileName)
    {
        try
        {
            using var content = new MultipartFormDataContent();
            using var streamContent = new StreamContent(stream);
            streamContent.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("application/pdf");
            content.Add(streamContent, "file", fileName);

            var response = await _httpClient.PostAsync("api/archivos/subir-ruc", content);
            if (response.IsSuccessStatusCode)
            {
                var doc = await response.Content.ReadFromJsonAsync<System.Text.Json.JsonElement>();
                if (doc.TryGetProperty("url", out var urlProp))
                {
                    return (true, urlProp.GetString(), null);
                }
            }

            var err = await response.Content.ReadAsStringAsync();
            return (false, null, string.IsNullOrWhiteSpace(err) ? "Error al subir el archivo PDF." : err);
        }
        catch (Exception ex)
        {
            return (false, null, ex.Message);
        }
    }

    public async Task<(bool Exito, string? Url, string? Mensaje)> SubirImagenAsync(Stream stream, string fileName)
    {
        try
        {
            using var content = new MultipartFormDataContent();
            using var streamContent = new StreamContent(stream);
            var extension = System.IO.Path.GetExtension(fileName).ToLowerInvariant();
            var mimeType = extension switch
            {
                ".png" => "image/png",
                ".webp" => "image/webp",
                _ => "image/jpeg"
            };
            streamContent.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue(mimeType);
            content.Add(streamContent, "file", fileName);

            var response = await _httpClient.PostAsync("api/archivos/subir-imagen", content);
            if (response.IsSuccessStatusCode)
            {
                var doc = await response.Content.ReadFromJsonAsync<System.Text.Json.JsonElement>();
                if (doc.TryGetProperty("url", out var urlProp))
                {
                    return (true, urlProp.GetString(), null);
                }
            }

            var err = await response.Content.ReadAsStringAsync();
            return (false, null, string.IsNullOrWhiteSpace(err) ? "Error al subir la imagen." : err);
        }
        catch (Exception ex)
        {
            return (false, null, ex.Message);
        }
    }

    public async Task<List<LocalModel>> GetLocalesPendientesAsync(EstadoAprobacionLocalModel? estado = null)
    {
        try
        {
            var url = estado.HasValue ? $"api/locales/pendientes?estado={estado.Value}" : "api/locales/pendientes";
            var result = await _httpClient.GetFromJsonAsync<List<LocalModel>>(url);
            return result ?? new List<LocalModel>();
        }
        catch
        {
            return new List<LocalModel>();
        }
    }

    public async Task<(bool Exito, LocalModel? Datos, string? Mensaje)> AprobarLocalAsync(Guid id)
    {
        try
        {
            var response = await _httpClient.PostAsync($"api/locales/{id}/aprobar", null);
            if (response.IsSuccessStatusCode)
            {
                var local = await response.Content.ReadFromJsonAsync<LocalModel>();
                return (true, local, null);
            }

            return (false, null, "Error al aprobar el local.");
        }
        catch (Exception ex)
        {
            return (false, null, ex.Message);
        }
    }

    public async Task<(bool Exito, LocalModel? Datos, string? Mensaje)> RechazarLocalAsync(Guid id, string motivo)
    {
        try
        {
            var response = await _httpClient.PostAsJsonAsync($"api/locales/{id}/rechazar", new { Motivo = motivo });
            if (response.IsSuccessStatusCode)
            {
                var local = await response.Content.ReadFromJsonAsync<LocalModel>();
                return (true, local, null);
            }

            return (false, null, "Error al rechazar el local.");
        }
        catch (Exception ex)
        {
            return (false, null, ex.Message);
        }
    }
}
