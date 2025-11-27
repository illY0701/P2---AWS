# Script para Testar TODOS os Servicos AWS Implantados
# Testa EC2, RDS, S3, ECS, Lambda e API Gateway

Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "  TESTANDO SERVICOS AWS IMPLANTADOS" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

$ServicosOK = 0
$TotalServicos = 6

# Obter outputs do Terraform
Write-Host "`n[1/7] Obtendo outputs do Terraform..." -ForegroundColor Yellow
Set-Location terraform

$OutputsRaw = terraform output -json 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] Erro ao obter outputs do Terraform" -ForegroundColor Red
    Set-Location ..
    exit 1
}

try {
    $Outputs = $OutputsRaw | ConvertFrom-Json
    Write-Host "[OK] Outputs obtidos com sucesso" -ForegroundColor Green
} catch {
    Write-Host "[X] Erro ao parsear outputs JSON" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Set-Location ..

# ============================================================================
# TESTE 1: EC2
# ============================================================================

Write-Host "`n[2/7] Testando EC2 Web Server..." -ForegroundColor Yellow

if ($Outputs.ec2_public_ip -and $Outputs.ec2_public_ip.value) {
    $EC2_IP = $Outputs.ec2_public_ip.value
    Write-Host "IP: $EC2_IP" -ForegroundColor White
    
    try {
        $Response = Invoke-WebRequest -Uri "http://$EC2_IP" -TimeoutSec 10 -UseBasicParsing 2>&1
        if ($Response.StatusCode -eq 200) {
            Write-Host "[OK] EC2 FUNCIONANDO! Status: 200" -ForegroundColor Green
            $ServicosOK++
        } else {
            Write-Host "[!] EC2 respondeu com status: $($Response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[X] EC2 nao respondeu: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "    (Isso pode ser normal se o SG nao permite HTTP de fora)" -ForegroundColor Gray
    }
} else {
    Write-Host "[!] Output ec2_public_ip nao encontrado" -ForegroundColor Yellow
}

# ============================================================================
# TESTE 2: API GATEWAY + LAMBDA
# ============================================================================

Write-Host "`n[3/7] Testando API Gateway + Lambda..." -ForegroundColor Yellow

if ($Outputs.api_gateway_url -and $Outputs.api_gateway_url.value) {
    $API_URL = $Outputs.api_gateway_url.value
    Write-Host "URL: $API_URL" -ForegroundColor White
    
    # Testar endpoint /status
    $StatusURL = "$API_URL/status"
    Write-Host "  Testando: $StatusURL" -ForegroundColor Gray
    
    try {
        $Response = Invoke-RestMethod -Uri $StatusURL -Method Get -TimeoutSec 10
        Write-Host "[OK] Lambda STATUS respondeu!" -ForegroundColor Green
        Write-Host "     Status: $($Response.status)" -ForegroundColor Cyan
        $ServicosOK++
    } catch {
        Write-Host "[X] Lambda STATUS falhou: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "[!] Output api_gateway_url nao encontrado" -ForegroundColor Yellow
}

# ============================================================================
# TESTE 3: S3
# ============================================================================

Write-Host "`n[4/7] Testando S3 Buckets..." -ForegroundColor Yellow

if ($Outputs.s3_assets_bucket_arn -and $Outputs.s3_assets_bucket_arn.value) {
    $BucketARN = $Outputs.s3_assets_bucket_arn.value
    $BucketName = $BucketARN -replace 'arn:aws:s3:::', ''
    Write-Host "Bucket: $BucketName" -ForegroundColor White
    
    try {
        $S3List = aws s3 ls "s3://$BucketName/" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] S3 ACESSIVEL!" -ForegroundColor Green
            if ($S3List) {
                Write-Host "     Arquivos encontrados:" -ForegroundColor Cyan
                Write-Host ($S3List | Select-Object -First 5 | Out-String) -ForegroundColor Gray
            }
            $ServicosOK++
        } else {
            Write-Host "[X] Erro ao acessar S3: $S3List" -ForegroundColor Red
        }
    } catch {
        Write-Host "[X] Erro ao listar S3: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "[!] Output s3_assets_bucket_arn nao encontrado" -ForegroundColor Yellow
}

# ============================================================================
# TESTE 4: ECS
# ============================================================================

Write-Host "`n[5/7] Testando ECS Cluster..." -ForegroundColor Yellow

if ($Outputs.ecs_cluster_name -and $Outputs.ecs_cluster_name.value) {
    $ClusterName = $Outputs.ecs_cluster_name.value
    Write-Host "Cluster: $ClusterName" -ForegroundColor White
    
    try {
        $ECSList = aws ecs list-tasks --cluster $ClusterName 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] ECS CLUSTER ATIVO!" -ForegroundColor Green
            $TasksJSON = $ECSList | ConvertFrom-Json
            $TaskCount = ($TasksJSON.taskArns).Count
            Write-Host "     Tasks em execucao: $TaskCount" -ForegroundColor Cyan
            $ServicosOK++
        } else {
            Write-Host "[X] Erro ao acessar ECS: $ECSList" -ForegroundColor Red
        }
    } catch {
        Write-Host "[X] Erro ao listar tasks: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "[!] Output ecs_cluster_name nao encontrado" -ForegroundColor Yellow
}

# ============================================================================
# TESTE 5: RDS
# ============================================================================

Write-Host "`n[6/7] Testando RDS Database..." -ForegroundColor Yellow

if ($Outputs.rds_database_name -and $Outputs.rds_database_name.value) {
    $DBName = $Outputs.rds_database_name.value
    Write-Host "Database: $DBName" -ForegroundColor White
    
    # Verificar se a instancia esta disponivel
    $DBIdentifier = "cloud-computing-av2-dev-db"
    
    try {
        $RDSStatus = aws rds describe-db-instances --db-instance-identifier $DBIdentifier --query 'DBInstances[0].DBInstanceStatus' --output text 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] RDS STATUS: $RDSStatus" -ForegroundColor Green
            if ($RDSStatus -eq "available") {
                $ServicosOK++
            }
        } else {
            Write-Host "[X] Erro ao verificar RDS: $RDSStatus" -ForegroundColor Red
        }
    } catch {
        Write-Host "[X] Erro ao consultar RDS: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "[!] Output rds_database_name nao encontrado" -ForegroundColor Yellow
}

# ============================================================================
# TESTE 6: LAMBDA FUNCTIONS
# ============================================================================

Write-Host "`n[7/7] Testando Lambda Functions..." -ForegroundColor Yellow

$LambdaFunctions = @("lambda_process_function_name", "lambda_status_function_name", "lambda_data_function_name")
$LambdasOK = 0

foreach ($FuncOutput in $LambdaFunctions) {
    if ($Outputs.$FuncOutput -and $Outputs.$FuncOutput.value) {
        $FuncName = $Outputs.$FuncOutput.value
        
        try {
            $LambdaInfo = aws lambda get-function --function-name $FuncName 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  [OK] $FuncName" -ForegroundColor Green
                $LambdasOK++
            } else {
                Write-Host "  [X] $FuncName falhou" -ForegroundColor Red
            }
        } catch {
            Write-Host "  [X] Erro ao verificar $FuncName" -ForegroundColor Red
        }
    }
}

if ($LambdasOK -eq 3) {
    Write-Host "[OK] TODAS as 3 Lambdas estao ativas!" -ForegroundColor Green
    $ServicosOK++
} else {
    Write-Host "[!] Apenas $LambdasOK/3 Lambdas ativas" -ForegroundColor Yellow
}

# ============================================================================
# RESULTADO FINAL
# ============================================================================

Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "  RESULTADO DOS TESTES" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

Write-Host "`nServicos funcionando: $ServicosOK / $TotalServicos" -ForegroundColor White

if ($ServicosOK -eq $TotalServicos) {
    Write-Host "`n*** TODOS OS SERVICOS FUNCIONANDO! ***" -ForegroundColor Green
    exit 0
} elseif ($ServicosOK -ge 4) {
    Write-Host "`n*** MAIORIA DOS SERVICOS FUNCIONANDO ***" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "`n*** VARIOS SERVICOS COM PROBLEMAS ***" -ForegroundColor Red
    exit 1
}

