# Script para Resolver Problema de Arquivo Grande - Solução Rápida

Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "  RESOLVENDO PROBLEMA DE ARQUIVO GRANDE" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

Write-Host "`n[AVISO] Isso vai remover o histórico Git e começar do zero" -ForegroundColor Yellow
Write-Host "        Mas como é um repositório novo, não tem problema!" -ForegroundColor Yellow

$confirm = Read-Host "`nContinuar? (S/N)"

if ($confirm -ne 'S' -and $confirm -ne 's') {
    Write-Host "Operacao cancelada." -ForegroundColor Yellow
    exit 0
}

# Remover .git
Write-Host "`n[1/5] Removendo histórico Git..." -ForegroundColor Yellow
Remove-Item -Recurse -Force .git -ErrorAction SilentlyContinue
Write-Host "[OK] Histórico removido" -ForegroundColor Green

# Inicializar novo Git
Write-Host "`n[2/5] Inicializando novo Git..." -ForegroundColor Yellow
git init
Write-Host "[OK] Git inicializado" -ForegroundColor Green

# Adicionar remote
Write-Host "`n[3/5] Configurando remote..." -ForegroundColor Yellow
git remote add origin https://github.com/illY0701/P2---AWS.git
Write-Host "[OK] Remote configurado" -ForegroundColor Green

# Verificar .gitignore
Write-Host "`n[4/5] Verificando .gitignore..." -ForegroundColor Yellow
if (Test-Path ".gitignore") {
    Write-Host "[OK] .gitignore existe" -ForegroundColor Green
} else {
    Write-Host "[!] .gitignore não encontrado" -ForegroundColor Yellow
}

# Adicionar arquivos
Write-Host "`n[5/5] Adicionando arquivos..." -ForegroundColor Yellow
git add .
Write-Host "[OK] Arquivos adicionados" -ForegroundColor Green

Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "  PRÓXIMOS PASSOS" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

Write-Host "`nExecute os comandos:" -ForegroundColor White
Write-Host "  git commit -m 'Projeto Cloud Computing AWS - Avaliação 02'" -ForegroundColor Cyan
Write-Host "  git branch -M main" -ForegroundColor Cyan
Write-Host "  git push -u origin main" -ForegroundColor Cyan

Write-Host ""

