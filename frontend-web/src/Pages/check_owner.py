import re
with open(r'C:\Users\denni\OneDrive\Documentos\APLICACIONES MOVILES Y WEB\SistemaGastronomico-main\frontend-web\src\Pages\Home.razor', 'r', encoding='utf-8-sig') as f:
    text = f.read()
match = re.search(r'(@if \(miLocal != null\).*?<div class="row g-4 mb-4">)', text, re.DOTALL)
if match:
    print(match.group(1))
else:
    print("Not found")
