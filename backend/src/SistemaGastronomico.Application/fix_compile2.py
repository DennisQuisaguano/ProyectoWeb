import glob, re

files = [
    r'C:\Users\denni\OneDrive\Documentos\APLICACIONES MOVILES Y WEB\SistemaGastronomico-main\backend\src\SistemaGastronomico.Application\Usuarios\Commands\RequestManualPasswordReset\RequestManualPasswordResetCommand.cs',
    r'C:\Users\denni\OneDrive\Documentos\APLICACIONES MOVILES Y WEB\SistemaGastronomico-main\backend\src\SistemaGastronomico.Application\Usuarios\Commands\ApprovePasswordReset\ApprovePasswordResetCommand.cs',
    r'C:\Users\denni\OneDrive\Documentos\APLICACIONES MOVILES Y WEB\SistemaGastronomico-main\backend\src\SistemaGastronomico.Application\Usuarios\Commands\RejectPasswordReset\RejectPasswordResetCommand.cs'
]

for filepath in files:
    with open(filepath, 'r', encoding='utf-8-sig') as f:
        text = f.read()
    
    # Replace the multi-line Dictionary with simple throw new System.Exception
    text = re.sub(r'throw new ValidationException\(new Dictionary<string, string\[\]>\s*\{\s*\{\s*".*?",\s*new\[\]\s*\{\s*"(.*?)"\s*\}\s*\}\s*\}\);', r'throw new System.Exception("\1");', text, flags=re.DOTALL)
    
    text = text.replace('._passwordHasher.Hash(', '._passwordHasher.HashPassword(')
    
    with open(filepath, 'w', encoding='utf-8-sig') as f:
        f.write(text)

print("done")
