# Script para tentar deploy até sucesso
$maxAttempts = 10
$attempt = 0
$success = $false

while (-not $success -and $attempt -lt $maxAttempts) {
    $attempt++
    Write-Host "`n=== Tentativa $attempt de $maxAttempts ===" -ForegroundColor Cyan
    
    $result = terraform apply -auto-approve 2>&1
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host "`n✅ SUCESSO! Deploy concluído!" -ForegroundColor Green
        $success = $true
        break
    } else {
        Write-Host "`n❌ Erro na tentativa $attempt" -ForegroundColor Red
        
        # Verificar se é erro de RDS ainda criando
        if ($result -match "not in available state" -or $result -match "DBInstanceAlreadyExists") {
            Write-Host "⏳ RDS ainda está sendo criado. Aguardando 2 minutos..." -ForegroundColor Yellow
            Start-Sleep -Seconds 120
        } else {
            Write-Host "⏳ Aguardando 30 segundos antes de tentar novamente..." -ForegroundColor Yellow
            Start-Sleep -Seconds 30
        }
    }
}

if (-not $success) {
    Write-Host "`n❌ Falhou após $maxAttempts tentativas" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`n🎉 Deploy concluído com sucesso!" -ForegroundColor Green
    terraform output
    exit 0
}

