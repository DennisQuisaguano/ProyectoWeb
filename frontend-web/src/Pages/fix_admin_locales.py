import re

filepath = r'C:\Users\denni\OneDrive\Documentos\APLICACIONES MOVILES Y WEB\SistemaGastronomico-main\frontend-web\src\Pages\AdminGestionLocales.razor'

with open(filepath, 'rb') as f:
    b = f.read()

# Fix \xef\xbf\xbd corruption (often seen as dark, danger)
text = b.decode('utf-8-sig', errors='replace')
text = text.replace('dark', 'dark')
text = text.replace('danger', 'danger')

# If the file was literally saved with 'dárk', 'dánger', fix those too
text = text.replace('dárk', 'dark')
text = text.replace('dánger', 'danger')
text = text.replace('menúsaje', 'mensaje')

# Now upgrade the "Suspender" and "Activar" buttons to look much more professional.
# Replace RUC Button
old_ruc = r'<a href="@ObtenerUrlArchivo\(local\.CertificadoRucUrl\)" target="_blank" class="btn btn-outline-secondary btn-sm rounded-3 fw-semibold text-dark" title="Ver PDF RUC">\s*<i class="bi bi-file-earmark-pdf text-danger me-1"></i> RUC\s*</a>'
new_ruc = r'''<a href="@ObtenerUrlArchivo(local.CertificadoRucUrl)" target="_blank" class="btn btn-light btn-sm rounded-pill px-3 border shadow-sm fw-bold text-dark d-flex align-items-center gap-1 hover-elevate" title="Ver Documento RUC">
                                    <i class="bi bi-file-earmark-pdf-fill text-danger"></i> RUC
                                </a>'''
text = re.sub(old_ruc, new_ruc, text)

# Replace Suspender Button
old_suspender = r'<button class="btn btn-outline-danger btn-sm rounded-3 fw-semibold" @onclick="\(\) => AbrirModalDeshabilitar\(local\)" title="Deshabilitar de la plataforma">\s*Suspender\s*</button>'
new_suspender = r'''<button class="btn btn-danger btn-sm rounded-pill px-3 shadow-sm fw-bold d-flex align-items-center gap-1 hover-elevate" @onclick="() => AbrirModalDeshabilitar(local)" title="Suspender operaciones del local">
                                    <i class="bi bi-pause-circle-fill"></i> Suspender
                                </button>'''
text = re.sub(old_suspender, new_suspender, text)

# Replace Activar Button
old_activar = r'<button class="btn btn-outline-primary btn-sm rounded-3 fw-semibold" @onclick="\(\) => ConfirmarHabilitar\(local\)" title="Habilitar en plataforma">\s*Activar\s*</button>'
new_activar = r'''<button class="btn btn-primary btn-sm rounded-pill px-3 shadow-sm fw-bold d-flex align-items-center gap-1 hover-elevate" @onclick="() => ConfirmarHabilitar(local)" title="Reactivar operaciones del local">
                                    <i class="bi bi-play-circle-fill"></i> Activar
                                </button>'''
text = re.sub(old_activar, new_activar, text)

# In case my exact regex didn't match due to spacing/mojibake, I'll do a fallback replace on the class strings:
text = text.replace('btn btn-outline-danger btn-sm rounded-3 fw-semibold', 'btn btn-danger btn-sm rounded-pill px-3 shadow-sm fw-bold d-flex align-items-center gap-1')
text = text.replace('btn btn-outline-primary btn-sm rounded-3 fw-semibold', 'btn btn-primary btn-sm rounded-pill px-3 shadow-sm fw-bold d-flex align-items-center gap-1')
text = text.replace('btn btn-outline-secondary btn-sm rounded-3 fw-semibold text-dark', 'btn btn-light btn-sm rounded-pill px-3 border shadow-sm fw-bold text-dark d-flex align-items-center gap-1')


with open(filepath, 'w', encoding='utf-8-sig') as f:
    f.write(text)

print("Fixed classes and buttons in AdminGestionLocales!")
