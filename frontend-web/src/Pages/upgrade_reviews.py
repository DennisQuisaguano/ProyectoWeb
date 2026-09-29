import re

filepath = r'C:\Users\denni\OneDrive\Documentos\APLICACIONES MOVILES Y WEB\SistemaGastronomico-main\frontend-web\src\Pages\AdminGestionLocales.razor'

with open(filepath, 'rb') as f:
    text = f.read().decode('utf-8-sig', errors='replace')

# 1. Clean up remaining Mojibakes in the file (especially in the modal)
text = text.replace('reseas', 'reseñas')
text = text.replace('Reseas', 'Reseñas')
text = text.replace('Ests', '¿Estás')
text = text.replace('completamente', 'completamente')
text = text.replace('comentarios', 'comentarios')
text = text.replace('ms-2', 'ms-2')
text = text.replace('recibidas', 'recibidas')
text = text.replace('text-dark', 'text-dark')
text = text.replace('text-danger', 'text-danger')
text = text.replace('an', 'aún')
text = text.replace('Alfabtico', 'Alfabético')

# 2. Upgrade the "Ver reseñas" button in the table so it's a real button, not a tiny link
old_ver_resenas = r'<button class="btn btn-sm btn-link text-decoration-none p-0 small" @onclick="\(\) => AbrirModalResenas\(local\)">Ver rese.*?as</button>'
new_ver_resenas = r'''<button class="btn btn-light btn-sm rounded-pill px-3 shadow-sm text-primary fw-bold border" @onclick="() => AbrirModalResenas(local)">
                                    <i class="bi bi-star-fill text-warning me-1"></i> Reseñas
                                </button>'''
text = re.sub(old_ver_resenas, new_ver_resenas, text)

# Just in case the previous replace failed because of exact match, let's also do a manual string replace
text = text.replace('<button class="btn btn-sm btn-link text-decoration-none p-0 small" @onclick="() => AbrirModalResenas(local)">Ver reseñas</button>', 
                    '<button class="btn btn-light btn-sm rounded-pill px-3 shadow-sm text-primary fw-bold border" @onclick="() => AbrirModalResenas(local)"><i class="bi bi-star-fill text-warning me-1"></i> Reseñas</button>')

# 3. Add the "Suspender" button to the modal footer
old_modal_footer = r'<div class="modal-footer border-top-0">\s*<button type="button" class="btn btn-secondary px-4" @onclick="CerrarModalResenas">Cerrar</button>\s*</div>'
new_modal_footer = r'''<div class="modal-footer border-top-0 bg-light rounded-bottom-4 justify-content-between">
                    <div>
                        @if (localSeleccionado.EstaAbierto)
                        {
                            <button type="button" class="btn btn-rose px-4 rounded-pill fw-bold shadow-sm d-flex align-items-center gap-1" @onclick="() => { CerrarModalResenas(); AbrirModalDeshabilitar(localSeleccionado); }">
                                <i class="bi bi-pause-circle-fill"></i> Suspender Local
                            </button>
                        }
                    </div>
                    <button type="button" class="btn btn-secondary px-4 rounded-pill fw-bold" @onclick="CerrarModalResenas">Cerrar</button>
                </div>'''

text = re.sub(old_modal_footer, new_modal_footer, text)

with open(filepath, 'w', encoding='utf-8-sig') as f:
    f.write(text)

print("Modal reviews upgraded and mojibakes fixed!")
