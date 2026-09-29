import re

filepath = r'C:\Users\denni\OneDrive\Documentos\APLICACIONES MOVILES Y WEB\SistemaGastronomico-main\frontend-web\src\Pages\RevisionLocales.razor'

with open(filepath, 'rb') as f:
    b = f.read()

text = b.decode('utf-8-sig', errors='replace')
text = text.replace('\ufffd', '') # This removes the replacement character!

# Now do the replacements
text = text.replace('Validacin RUC', 'Validación de Locales')
text = text.replace('Validacin de Documentos RUC', 'Validación de Locales')
text = text.replace('Validación de Documentos RUC', 'Validación de Locales')

# Fix colors of filters
text = text.replace('btn-warning text-dark', 'btn-primary')
text = text.replace('btn-warning text-drk', 'btn-primary') # if dark was corrupted
text = text.replace('btn-success', 'btn-primary')
text = text.replace('btn-danger', 'btn-primary')
text = text.replace('btn-dnger', 'btn-primary')

# Fix campus color
text = text.replace('badge bg-light text-dark border', 'badge bg-primary text-white border-0 shadow-sm')
text = text.replace('badge bg-light text-drk border', 'badge bg-primary text-white border-0 shadow-sm')
text = text.replace('<i class="bi bi-geo-alt me-1 text-primary"></i>', '<i class="bi bi-geo-alt-fill me-1 text-white"></i>')

# Fix default filter
text = text.replace('filtroEstado = EstadoAprobacionLocalModel.Pendiente;', 'filtroEstado = null;')

# Verify modal PDF already exists or needs to be fixed.
old_pdf_btn = r'<a href="@fullUrl" target="_blank" class="btn btn-outline-d.*?rk btn-sm rounded-3 fw-bold px-3">\s*<i class="bi bi-file-earmark-pdf text-d.*?nger me-1"></i> Ver RUC\s*</a>'
new_pdf_btn = r'''<button class="btn btn-light border text-dark btn-sm rounded-pill fw-bold px-3 shadow-sm d-flex align-items-center gap-1 hover-elevate" @onclick="() => AbrirModalPdf(fullUrl)">
                                            <i class="bi bi-file-earmark-pdf-fill text-danger fs-6"></i> Ver RUC
                                        </button>'''
text = re.sub(old_pdf_btn, new_pdf_btn, text)

# Just in case the regex doesn't match, we can do a normal replace for the precise string from previous logs
# From logs: <a href="@fullUrl" target="_blank" class="btn btn-outline-dark btn-sm rounded-3 fw-bold px-3">
#                                             <i class="bi bi-file-earmark-pdf text-danger me-1"></i> Ver RUC
#                                         </a>
text = re.sub(r'<a href="@fullUrl" target="_blank" class="btn btn-outline-[a-z]* btn-sm rounded-3 fw-bold px-3">.*?Ver RUC.*?</a>', new_pdf_btn, text, flags=re.DOTALL)

with open(filepath, 'w', encoding='utf-8-sig') as f:
    f.write(text)

print("Properly replaced everything.")
