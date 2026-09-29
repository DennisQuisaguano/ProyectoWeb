import re

filepath = r'C:\Users\denni\OneDrive\Documentos\APLICACIONES MOVILES Y WEB\SistemaGastronomico-main\backend\src\SistemaGastronomico.Infrastructure\DependencyInjection.cs'

with open(filepath, 'rb') as f:
    text = f.read().decode('utf-8-sig', errors='replace')

new_events = """options.Events = new JwtBearerEvents
            {
                OnMessageReceived = context =>
                {
                    var accessToken = context.Request.Query["access_token"];
                    var path = context.HttpContext.Request.Path;
                    if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/hubs/notificaciones"))
                    {
                        context.Token = accessToken;
                    }
                    return Task.CompletedTask;
                },
                OnAuthenticationFailed = context =>"""

text = text.replace("options.Events = new JwtBearerEvents\r\n            {\r\n                OnAuthenticationFailed = context =>", new_events)
text = text.replace("options.Events = new JwtBearerEvents\n            {\n                OnAuthenticationFailed = context =>", new_events)

with open(filepath, 'w', encoding='utf-8-sig') as f:
    f.write(text)

print("done")
