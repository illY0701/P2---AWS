# Resolver Lock do Terraform
Write-Host "Resolvendo lock do estado do Terraform..." -ForegroundColor Cyan

# Matar processos
Get-Process terraform -ErrorAction SilentlyContinue | Stop-Process -Force
Write-Host "✓ Processos do Terraform encerrados" -ForegroundColor Green

# Remover lock file se existir
if (Test-Path ".terraform.tfstate.lock.info") {
    Remove-Item ".terraform.tfstate.lock.info" -Force
    Write-Host "✓ Arquivo de lock removido" -ForegroundColor Green
}

Write-Host "`nAgora você pode executar:" -ForegroundColor Yellow
Write-Host "terraform apply -auto-approve" -ForegroundColor White



