namespace src.Services;

using System.Net.Http.Headers;
using Microsoft.JSInterop;

public class AuthHeaderHandler : DelegatingHandler
{
    private readonly IJSRuntime _jsRuntime;

    public AuthHeaderHandler(IJSRuntime jsRuntime)
    {
        _jsRuntime = jsRuntime;
    }

    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        try
        {
            var token = await _jsRuntime.InvokeAsync<string?>("localStorage.getItem", "authToken", cancellationToken);
            if (!string.IsNullOrWhiteSpace(token) && request.Headers.Authorization == null)
            {
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
            }
        }
        catch
        {
            // Ignorar en caso de que JSInterop falle durante inicialización temprana
        }

        return await base.SendAsync(request, cancellationToken);
    }
}
