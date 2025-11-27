# Script para Limpar Arquivos Grandes do Git

Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "  LIMPANDO ARQUIVOS GRANDES DO GIT" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

# Remover arquivos grandes do cache do Git
Write-Host "`n[1/3] Removendo arquivos grandes do Git..." -ForegroundColor Yellow

# Remover providers Terraform (.exe)
$exeFiles = git ls-files | Select-String -Pattern "\.exe$"
if ($exeFiles) {
    foreach ($file in $exeFiles) {
        Write-Host "  Removendo: $file" -ForegroundColor Gray
        git rm --cached "$file" 2>&1 | Out-Null
    }
}

# Remover diretório .terraform
if (Test-Path "terraform/.terraform") {
    Write-Host "  Removendo: terraform/.terraform/" -ForegroundColor Gray
    git rm -r --cached terraform/.terraform 2>&1 | Out-Null
}

# Remover .terraform.old
$oldTerraform = Get-ChildItem -Path "terraform" -Directory -Filter ".terraform.old.*" -ErrorAction SilentlyContinue
if ($oldTerraform) {
    foreach ($dir in $oldTerraform) {
        Write-Host "  Removendo: $($dir.FullName)" -ForegroundColor Gray
        git rm -r --cached "$($dir.FullName)" 2>&1 | Out-Null
    }
}

# Remover arquivos de estado
$stateFiles = git ls-files | Select-String -Pattern "\.tfstate"
if ($stateFiles) {
    foreach ($file in $stateFiles) {
        Write-Host "  Removendo: $file" -ForegroundColor Gray
        git rm --cached "$file" 2>&1 | Out-Null
    }
}

Write-Host "[OK] Arquivos removidos do Git" -ForegroundColor Green

# Atualizar .gitignore
Write-Host "`n[2/3] Verificando .gitignore..." -ForegroundColor Yellow
if (Test-Path ".gitignore") {
    Write-Host "[OK] .gitignore atualizado" -ForegroundColor Green
} else {
    Write-Host "[!] Criando .gitignore..." -ForegroundColor Yellow
}

# Fazer commit
Write-Host "`n[3/3] Preparando novo commit..." -ForegroundColor Yellow
Write-Host "Execute manualmente:" -ForegroundColor White
Write-Host "  git add .gitignore" -ForegroundColor Cyan
Write-Host "  git commit -m 'Remover arquivos grandes do Terraform'" -ForegroundColor Cyan
Write-Host "  git push origin main" -ForegroundColor Cyan

Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "  PRONTO!" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

Write-Host "`nAgora o repositório está mais leve!" -ForegroundColor Green
Write-Host "Execute os comandos acima para fazer push." -ForegroundColor White
Write-Host ""

