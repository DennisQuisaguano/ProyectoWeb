import re

filepath = r'C:\Users\denni\OneDrive\Documentos\APLICACIONES MOVILES Y WEB\SistemaGastronomico-main\frontend-web\src\Pages\AdminGestionLocales.razor'

with open(filepath, 'r', encoding='utf-8-sig') as f:
    text = f.read()

text = text.replace('@(enRiesgo ? "text-dark")', '@(enRiesgo ? "text-danger" : "text-dark")')

with open(filepath, 'w', encoding='utf-8-sig') as f:
    f.write(text)
