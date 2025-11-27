# Script para Instalar Terraform Manualmente no Windows
# Não requer Chocolatey

Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "  INSTALACAO MANUAL DO TERRAFORM" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

# Verificar se já está instalado
Write-Host "`n[1/5] Verificando se Terraform ja esta instalado..." -ForegroundColor Yellow
try {
    $TerraformVersion = terraform --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Terraform ja esta instalado!" -ForegroundColor Green
        Write-Host "     Versao: $($TerraformVersion[0])" -ForegroundColor Cyan
        Write-Host "`nNenhuma acao necessaria!" -ForegroundColor Green
        exit 0
    }
} catch {
    Write-Host "[!] Terraform nao encontrado. Prosseguindo com instalacao..." -ForegroundColor Yellow
}

# Criar diretório para Terraform
Write-Host "`n[2/5] Criando diretorio para Terraform..." -ForegroundColor Yellow
$TerraformDir = "C:\terraform"
if (-not (Test-Path $TerraformDir)) {
    try {
        New-Item -ItemType Directory -Path $TerraformDir -Force | Out-Null
        Write-Host "[OK] Diretorio criado: $TerraformDir" -ForegroundColor Green
    } catch {
        Write-Host "[X] Erro ao criar diretorio. Execute como Administrador!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[OK] Diretorio ja existe: $TerraformDir" -ForegroundColor Green
}

# Baixar Terraform
Write-Host "`n[3/5] Baixando Terraform..." -ForegroundColor Yellow
Write-Host "     URL: https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_windows_amd64.zip" -ForegroundColor Gray

$DownloadUrl = "https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_windows_amd64.zip"
$ZipFile = "$env:TEMP\terraform.zip"
$TerraformExe = "$TerraformDir\terraform.exe"

try {
    # Baixar arquivo
    Write-Host "     Baixando (isso pode levar alguns segundos)..." -ForegroundColor Gray
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipFile -UseBasicParsing
    
    Write-Host "[OK] Download concluido!" -ForegroundColor Green
    
    # Extrair arquivo
    Write-Host "`n[4/5] Extraindo arquivo..." -ForegroundColor Yellow
    Expand-Archive -Path $ZipFile -DestinationPath $TerraformDir -Force
    
    Write-Host "[OK] Arquivo extraido!" -ForegroundColor Green
    
    # Limpar arquivo temporário
    Remove-Item $ZipFile -Force
    
} catch {
    Write-Host "[X] Erro ao baixar/extrair Terraform" -ForegroundColor Red
    Write-Host "     Erro: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nTente baixar manualmente:" -ForegroundColor Yellow
    Write-Host "     1. Acesse: https://developer.hashicorp.com/terraform/downloads" -ForegroundColor Cyan
    Write-Host "     2. Baixe a versao Windows (arquivo .zip)" -ForegroundColor Cyan
    Write-Host "     3. Extraia terraform.exe para: $TerraformDir" -ForegroundColor Cyan
    exit 1
}

# Adicionar ao PATH
Write-Host "`n[5/5] Adicionando Terraform ao PATH..." -ForegroundColor Yellow

$CurrentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)

if ($CurrentPath -notlike "*$TerraformDir*") {
    try {
        $NewPath = $CurrentPath + ";$TerraformDir"
        [Environment]::SetEnvironmentVariable("Path", $NewPath, [EnvironmentVariableTarget]::User)
        Write-Host "[OK] Terraform adicionado ao PATH do usuario!" -ForegroundColor Green
    } catch {
        Write-Host "[!] Nao foi possivel adicionar ao PATH automaticamente" -ForegroundColor Yellow
        Write-Host "     Adicione manualmente: $TerraformDir" -ForegroundColor Yellow
    }
} else {
    Write-Host "[OK] Terraform ja esta no PATH!" -ForegroundColor Green
}

# Verificar instalação
Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "  VERIFICANDO INSTALACAO" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

# Atualizar PATH na sessão atual
$env:Path += ";$TerraformDir"

# Aguardar um momento
Start-Sleep -Seconds 2

try {
    $TerraformVersion = & "$TerraformExe" --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n[OK] TERRAFORM INSTALADO COM SUCESSO!" -ForegroundColor Green
        Write-Host "     Versao: $($TerraformVersion[0])" -ForegroundColor Cyan
        Write-Host "     Localizacao: $TerraformExe" -ForegroundColor Cyan
        Write-Host "`nIMPORTANTE:" -ForegroundColor Yellow
        Write-Host "     Feche e reabra o PowerShell para usar o comando 'terraform'" -ForegroundColor Yellow
        Write-Host "     Ou use o caminho completo: $TerraformExe" -ForegroundColor Cyan
    } else {
        Write-Host "[!] Terraform instalado mas nao esta funcionando" -ForegroundColor Yellow
        Write-Host "     Tente fechar e reabrir o PowerShell" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[!] Erro ao verificar instalacao" -ForegroundColor Yellow
    Write-Host "     Tente fechar e reabrir o PowerShell" -ForegroundColor Yellow
    Write-Host "     Ou use: $TerraformExe --version" -ForegroundColor Cyan
}

Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "  PROXIMOS PASSOS" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

Write-Host "`n1. Feche e reabra o PowerShell" -ForegroundColor White
Write-Host "2. Execute: terraform --version" -ForegroundColor White
Write-Host "3. Se funcionar, volte para o projeto e execute:" -ForegroundColor White
Write-Host "   cd terraform" -ForegroundColor Cyan
Write-Host "   terraform init" -ForegroundColor Cyan
Write-Host ""

