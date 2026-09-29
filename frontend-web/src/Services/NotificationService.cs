using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.JSInterop;

namespace src.Services
{
    public class NotificationMessage
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public string Tipo { get; set; } = "info"; // "success", "error", "info"
        public string Mensaje { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime Fecha => CreatedAt;
        public bool Leida { get; set; } = false;
        public bool MostrarToast { get; set; } = true;
    }

    public class NotificationService : IAsyncDisposable
    {
        public event Action? OnChange;
        public event Action<NotificationMessage>? OnToastRequested;

        public List<NotificationMessage> Notificaciones { get; private set; } = new();

        private readonly HttpClient _httpClient;
        private readonly IJSRuntime _jsRuntime;
        private HubConnection? _hubConnection;

        public NotificationService(HttpClient httpClient, IJSRuntime jsRuntime)
        {
            _httpClient = httpClient;
            _jsRuntime = jsRuntime;
        }

        public async Task InitializeAsync()
        {
            if (_hubConnection is not null)
                return;

            // 1. Fetch unread notifications from API
            try
            {
                var response = await _httpClient.GetAsync("api/notificaciones");
                if (response.IsSuccessStatusCode)
                {
                    var fetched = await response.Content.ReadFromJsonAsync<List<NotificationMessage>>();
                    if (fetched != null && fetched.Any())
                    {
                        foreach (var notif in fetched)
                        {
                            notif.MostrarToast = false; // Don't toast old notifications
                            Notificaciones.Add(notif);
                        }
                        OnChange?.Invoke();
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching notifications: {ex.Message}");
            }

            // 2. Configure SignalR Hub
            var apiBaseUrl = _httpClient.BaseAddress?.ToString().TrimEnd('/');
            if (string.IsNullOrEmpty(apiBaseUrl)) return;

            var hubUrl = $"{apiBaseUrl}/hubs/notificaciones";
            _hubConnection = new HubConnectionBuilder()
                .WithUrl(hubUrl, options =>
                {
                    options.AccessTokenProvider = async () =>
                    {
                        try
                        {
                            return await _jsRuntime.InvokeAsync<string?>("localStorage.getItem", "authToken");
                        }
                        catch
                        {
                            return null;
                        }
                    };
                })
                .WithAutomaticReconnect()
                .Build();

            _hubConnection.On<NotificationMessage>("ReceiveNotification", (notif) =>
            {
                notif.MostrarToast = true;
                Notificaciones.Insert(0, notif);
                OnChange?.Invoke();
                OnToastRequested?.Invoke(notif);
            });

            try
            {
                await _hubConnection.StartAsync();
                Console.WriteLine("SignalR Notification Hub connected.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"SignalR Error: {ex.Message}");
            }
        }

        public void AddNotification(string tipo, string mensaje)
        {
            var noti = new NotificationMessage { Tipo = tipo, Mensaje = mensaje };
            Notificaciones.Insert(0, noti);
            OnChange?.Invoke();
            
            if (noti.MostrarToast)
            {
                OnToastRequested?.Invoke(noti);
            }
        }
        
        public void ShowSuccess(string mensaje) => AddNotification("success", mensaje);
        public void ShowError(string mensaje) => AddNotification("error", mensaje);
        public void ShowInfo(string mensaje) => AddNotification("info", mensaje);

        public async Task MarcarTodasComoLeidas()
        {
            var sinLeer = Notificaciones.Where(n => !n.Leida).ToList();
            if (sinLeer.Any())
            {
                foreach (var n in sinLeer) n.Leida = true;
                OnChange?.Invoke();

                // Send request to backend
                try
                {
                    await _httpClient.PostAsync("api/notificaciones/marcar-leidas", null);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error marking notifications as read: {ex.Message}");
                }
            }
        }

        public async ValueTask DisposeAsync()
        {
            if (_hubConnection is not null)
            {
                await _hubConnection.DisposeAsync();
            }
        }
    }
}
