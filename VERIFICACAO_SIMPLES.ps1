# Script de Verificacao Completa - Requisitos do Professor
# Garantir nota 10 na avaliacao

Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "  VERIFICACAO COMPLETA - PROJETO CLOUD COMPUTING AWS" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

$Pontuacao = 0
$Total = 10

# ============================================================================
# REQUISITO 1: DIAGRAMA DE ARQUITETURA [2 pontos]
# ============================================================================

Write-Host "`n[REQUISITO 1] Diagrama de Arquitetura (2 pontos)" -ForegroundColor Yellow
Write-Host "-------------------------------------------------------------------" -ForegroundColor Yellow

$DiagramFile = "architecture\diagram.md"

if (Test-Path $DiagramFile) {
    Write-Host "[OK] Arquivo encontrado: $DiagramFile" -ForegroundColor Green
    
    $Content = Get-Content $DiagramFile -Raw
    $Servicos = @("EC2", "RDS", "S3", "ECS", "Lambda", "API Gateway")
    $TodosEncontrados = $true
    
    foreach ($Servico in $Servicos) {
        if ($Content -match $Servico) {
            Write-Host "  [OK] Servico: $Servico" -ForegroundColor Green
        } else {
            Write-Host "  [X] FALTANDO: $Servico" -ForegroundColor Red
            $TodosEncontrados = $false
        }
    }
    
    if ($TodosEncontrados) {
        Write-Host "`n[APROVADO] Requisito 1: +2 pontos" -ForegroundColor Green
        $Pontuacao += 2
    } else {
        Write-Host "`n[REPROVADO] Requisito 1: 0 pontos" -ForegroundColor Red
    }
} else {
    Write-Host "[X] Arquivo NAO encontrado: $DiagramFile" -ForegroundColor Red
    Write-Host "`n[REPROVADO] Requisito 1: 0 pontos" -ForegroundColor Red
}

# ============================================================================
# REQUISITO 2: SCRIPT TERRAFORM [6 pontos]
# ============================================================================

Write-Host "`n[REQUISITO 2] Script Terraform (6 pontos)" -ForegroundColor Yellow
Write-Host "-------------------------------------------------------------------" -ForegroundColor Yellow

if (Test-Path "terraform") {
    Write-Host "[OK] Diretorio terraform/ encontrado" -ForegroundColor Green
    
    Set-Location terraform
    
    # Verificar arquivos principais
    $ArquivosTF = @("main.tf", "variables.tf", "outputs.tf", "providers.tf")
    foreach ($Arquivo in $ArquivosTF) {
        if (Test-Path $Arquivo) {
            Write-Host "  [OK] $Arquivo" -ForegroundColor Green
        }
    }
    
    # Verificar modulos
    $Modulos = @("ec2", "rds", "s3", "ecs", "lambda", "api-gateway")
    $TodosModulosOK = $true
    
    Write-Host "`nVerificando modulos:" -ForegroundColor White
    foreach ($Modulo in $Modulos) {
        if (Test-Path "modules\$Modulo") {
            Write-Host "  [OK] modules/$Modulo/" -ForegroundColor Green
        } else {
            Write-Host "  [X] FALTANDO: modules/$Modulo/" -ForegroundColor Red
            $TodosModulosOK = $false
        }
    }
    
    # Verificar Terraform
    Write-Host "`nVerificando Terraform:" -ForegroundColor White
    $TFVersion = terraform version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Terraform instalado" -ForegroundColor Green
    } else {
        Write-Host "  [X] Terraform NAO instalado" -ForegroundColor Red
        Set-Location ..
        Write-Host "`n[REPROVADO] Requisito 2: 0 pontos" -ForegroundColor Red
        continue
    }
    
    # Verificar inicializacao
    if (Test-Path ".terraform") {
        Write-Host "  [OK] Terraform inicializado" -ForegroundColor Green
    } else {
        Write-Host "  [!] Inicializando Terraform..." -ForegroundColor Yellow
        terraform init | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] Init executado" -ForegroundColor Green
        }
    }
    
    # Validar
    Write-Host "  [!] Validando configuracao..." -ForegroundColor Yellow
    $ValidateOutput = terraform validate 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] terraform validate: SUCESSO" -ForegroundColor Green
    } else {
        Write-Host "  [X] terraform validate: FALHOU" -ForegroundColor Red
        Set-Location ..
        Write-Host "`n[REPROVADO] Requisito 2: 0 pontos" -ForegroundColor Red
        continue
    }
    
    # Verificar state
    if (Test-Path "terraform.tfstate") {
        Write-Host "  [OK] State file existe - infraestrutura aplicada" -ForegroundColor Green
        
        # Verificar outputs
        $OutputsRaw = terraform output -json 2>&1
        if ($LASTEXITCODE -eq 0) {
            try {
                $Outputs = $OutputsRaw | ConvertFrom-Json
                $OutputCount = ($Outputs.PSObject.Properties).Count
                Write-Host "  [OK] $OutputCount outputs configurados" -ForegroundColor Green
            } catch {
                Write-Host "  [!] Outputs nao disponiveis" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "  [!] State nao existe - infraestrutura nao aplicada ainda" -ForegroundColor Yellow
    }
    
    Set-Location ..
    
    if ($TodosModulosOK) {
        Write-Host "`n[APROVADO] Requisito 2: +6 pontos" -ForegroundColor Green
        $Pontuacao += 6
    } else {
        Write-Host "`n[REPROVADO] Requisito 2: 0 pontos (faltam modulos)" -ForegroundColor Red
    }
} else {
    Write-Host "[X] Diretorio terraform/ NAO encontrado" -ForegroundColor Red
    Write-Host "`n[REPROVADO] Requisito 2: 0 pontos" -ForegroundColor Red
}

# ============================================================================
# REQUISITO 3: DASHBOARD GRAFANA [2 pontos]
# ============================================================================

Write-Host "`n[REQUISITO 3] Dashboard Grafana (2 pontos)" -ForegroundColor Yellow
Write-Host "-------------------------------------------------------------------" -ForegroundColor Yellow

if (Test-Path "grafana\dashboards") {
    Write-Host "[OK] Diretorio grafana/dashboards/ encontrado" -ForegroundColor Green
    
    $Dashboards = Get-ChildItem "grafana\dashboards" -Filter "*.json"
    
    if ($Dashboards.Count -gt 0) {
        Write-Host "[OK] Encontrados $($Dashboards.Count) dashboard(s) JSON" -ForegroundColor Green
        
        foreach ($Dashboard in $Dashboards) {
            Write-Host "  [OK] $($Dashboard.Name)" -ForegroundColor Green
            
            try {
                $DashContent = Get-Content $Dashboard.FullName -Raw | ConvertFrom-Json
                if ($DashContent.panels) {
                    $PanelCount = ($DashContent.panels).Count
                    Write-Host "      -> $PanelCount paineis configurados" -ForegroundColor Cyan
                }
            } catch {
                Write-Host "      [!] Erro ao analisar JSON" -ForegroundColor Yellow
            }
        }
        
        # Verificar datasource
        if (Test-Path "grafana\datasources.yml") {
            Write-Host "  [OK] datasources.yml configurado" -ForegroundColor Green
        }
        
        Write-Host "`n[APROVADO] Requisito 3: +2 pontos" -ForegroundColor Green
        $Pontuacao += 2
    } else {
        Write-Host "[X] Nenhum dashboard JSON encontrado" -ForegroundColor Red
        Write-Host "`n[REPROVADO] Requisito 3: 0 pontos" -ForegroundColor Red
    }
} else {
    Write-Host "[X] Diretorio grafana/dashboards/ NAO encontrado" -ForegroundColor Red
    Write-Host "`n[REPROVADO] Requisito 3: 0 pontos" -ForegroundColor Red
}

# ============================================================================
# RESULTADO FINAL
# ============================================================================

Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "  RESULTADO FINAL" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

Write-Host "`nPONTUACAO: $Pontuacao / $Total pontos" -ForegroundColor White

if ($Pontuacao -eq 10) {
    Write-Host "`n*** PROJETO COMPLETO - NOTA 10! ***" -ForegroundColor Green
    Write-Host "Todos os requisitos foram atendidos!" -ForegroundColor Green
    exit 0
} elseif ($Pontuacao -ge 7) {
    Write-Host "`n*** PROJETO QUASE COMPLETO ***" -ForegroundColor Yellow
    Write-Host "Faltam alguns itens para nota maxima." -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "`n*** PROJETO INCOMPLETO ***" -ForegroundColor Red
    Write-Host "Varios requisitos nao foram atendidos." -ForegroundColor Red
    exit 1
}

