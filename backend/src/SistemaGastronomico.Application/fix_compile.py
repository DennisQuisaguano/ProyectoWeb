import glob, re

files = [
    r'C:\Users\denni\OneDrive\Documentos\APLICACIONES MOVILES Y WEB\SistemaGastronomico-main\backend\src\SistemaGastronomico.Application\Usuarios\Commands\RequestManualPasswordReset\RequestManualPasswordResetCommand.cs',
    r'C:\Users\denni\OneDrive\Documentos\APLICACIONES MOVILES Y WEB\SistemaGastronomico-main\backend\src\SistemaGastronomico.Application\Usuarios\Commands\ApprovePasswordReset\ApprovePasswordResetCommand.cs',
    r'C:\Users\denni\OneDrive\Documentos\APLICACIONES MOVILES Y WEB\SistemaGastronomico-main\backend\src\SistemaGastronomico.Application\Usuarios\Commands\RejectPasswordReset\RejectPasswordResetCommand.cs'
]

for filepath in files:
    with open(filepath, 'rb') as f:
        text = f.read().decode('utf-8-sig', errors='replace')
    
    text = re.sub(r'throw new ValidationException\(new Dictionary<string, string\[\]> \{ \{ "(.*?)", new\[\] \{ "(.*?)" \} \} \}\);', r'throw new System.Exception("\2");', text)
    text = text.replace('._passwordHasher.Hash(', '._passwordHasher.HashPassword(')
    
    with open(filepath, 'w', encoding='utf-8-sig') as f:
        f.write(text)

print("done")
