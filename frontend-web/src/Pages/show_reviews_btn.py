import re

filepath = r'C:\Users\denni\OneDrive\Documentos\APLICACIONES MOVILES Y WEB\SistemaGastronomico-main\frontend-web\src\Pages\AdminGestionLocales.razor'

with open(filepath, 'rb') as f:
    text = f.read().decode('utf-8-sig')

# Replace the conditional block
old_block = r'''@if \(local\.TotalResenas > 0\)
\s*\{
\s*<div class="d-flex align-items-center gap-2">
\s*<span class="fw-bold.*?</span>
\s*<button class="btn btn-light btn-sm rounded-pill px-3 shadow-sm text-primary fw-bold border".*?</button>
\s*</div>
\s*\}
\s*else
\s*\{
\s*<span class="text-muted small">.*?</span>
\s*\}'''

new_block = '''<div class="d-flex flex-column align-items-start gap-2">
                            @if (local.TotalResenas > 0)
                            {
                                <span class="fw-bold @(enRiesgo ? "text-danger" : "text-dark")">
                                    <i class="bi bi-star-fill text-warning me-1"></i> @local.CalificacionPromedio.ToString("0.0") / 5
                                </span>
                            }
                            else
                            {
                                <span class="text-muted small">Sin calificaciones</span>
                            }
                            <button class="btn btn-light btn-sm rounded-pill px-3 shadow-sm text-primary fw-bold border" @onclick="() => AbrirModalResenas(local)">
                                <i class="bi bi-chat-left-text me-1"></i> Ver Reseñas
                            </button>
                        </div>'''

text = re.sub(old_block, new_block, text, flags=re.DOTALL)

with open(filepath, 'w', encoding='utf-8-sig') as f:
    f.write(text)

print("Always show reviews button!")
