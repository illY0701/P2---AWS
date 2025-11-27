# Correcao Direta via AWS CLI

Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "  CORRIGINDO SERVICOS DIRETAMENTE" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

Set-Location terraform

# Obter outputs
$Outputs = terraform output -json | ConvertFrom-Json

# ============================================================================
# CORRIGIR 1: Lambda Functions
# ============================================================================

Write-Host "`n[1/3] Atualizando Lambda Functions..." -ForegroundColor Yellow

$LambdaFunctions = @{
    "cloud-computing-av2-dev-process" = "modules\lambda\lambda_process.zip"
    "cloud-computing-av2-dev-status" = "modules\lambda\lambda_status.zip"
    "cloud-computing-av2-dev-data" = "modules\lambda\lambda_data.zip"
}

foreach ($FuncName in $LambdaFunctions.Keys) {
    $ZipPath = $LambdaFunctions[$FuncName]
    
    Write-Host "  Atualizando: $FuncName" -ForegroundColor White
    
    $UpdateResult = aws lambda update-function-code --function-name $FuncName --zip-file "fileb://$ZipPath" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    [OK] Atualizado!" -ForegroundColor Green
    } else {
        Write-Host "    [X] Erro: $UpdateResult" -ForegroundColor Red
    }
}

# ============================================================================
# CORRIGIR 2: Security Group EC2 - Adicionar regra HTTP
# ============================================================================

Write-Host "`n[2/3] Corrigindo Security Group do EC2..." -ForegroundColor Yellow

# Obter instance ID
$InstanceID = $Outputs.ec2_instance_id.value

if ($InstanceID) {
    Write-Host "  Instance ID: $InstanceID" -ForegroundColor White
    
    # Obter Security Groups da instancia
    $SGInfo = aws ec2 describe-instances --instance-ids $InstanceID --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' --output text 2>&1
    
    if ($LASTEXITCODE -eq 0 -and $SGInfo) {
        Write-Host "  Security Group: $SGInfo" -ForegroundColor White
        
        # Tentar adicionar regra HTTP
        Write-Host "  Adicionando regra HTTP (porta 80)..." -ForegroundColor White
        
        $AddHTTP = aws ec2 authorize-security-group-ingress --group-id $SGInfo --protocol tcp --port 80 --cidr 0.0.0.0/0 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] Regra HTTP adicionada!" -ForegroundColor Green
        } else {
            if ($AddHTTP -match "already exists") {
                Write-Host "  [OK] Regra HTTP ja existe!" -ForegroundColor Green
            } else {
                Write-Host "  [!] $AddHTTP" -ForegroundColor Yellow
            }
        }
    }
}

# ============================================================================
# CORRIGIR 3: Verificar se EC2 tem Nginx rodando
# ============================================================================

Write-Host "`n[3/3] Verificando servico web no EC2..." -ForegroundColor Yellow

if ($InstanceID) {
    # Verificar status da instancia
    $InstanceState = aws ec2 describe-instances --instance-ids $InstanceID --query 'Reservations[0].Instances[0].State.Name' --output text 2>&1
    
    Write-Host "  Estado da instancia: $InstanceState" -ForegroundColor White
    
    if ($InstanceState -eq "running") {
        Write-Host "  [OK] Instancia rodando!" -ForegroundColor Green
        
        # Se quiser, pode tentar conectar via SSM e verificar nginx
        Write-Host "  Verificando se Nginx esta instalado..." -ForegroundColor White
        
        $CheckNginx = aws ssm send-command --instance-ids $InstanceID --document-name "AWS-RunShellScript" --parameters 'commands=["systemctl status nginx || service nginx status"]' --query 'Command.CommandId' --output text 2>&1
        
        if ($LASTEXITCODE -eq 0 -and $CheckNginx) {
            Write-Host "  [OK] Comando enviado para verificar Nginx" -ForegroundColor Green
            Start-Sleep -Seconds 3
            
            # Pegar resultado
            $Result = aws ssm get-command-invocation --command-id $CheckNginx --instance-id $InstanceID 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                if ($Result -match "active.*running") {
                    Write-Host "  [OK] Nginx esta rodando!" -ForegroundColor Green
                } else {
                    Write-Host "  [!] Nginx pode nao estar rodando" -ForegroundColor Yellow
                    Write-Host "  Tentando iniciar Nginx..." -ForegroundColor White
                    
                    $StartNginx = aws ssm send-command --instance-ids $InstanceID --document-name "AWS-RunShellScript" --parameters 'commands=["sudo systemctl start nginx || sudo service nginx start"]' 2>&1
                }
            }
        }
    } else {
        Write-Host "  [!] Instancia nao esta running: $InstanceState" -ForegroundColor Yellow
    }
}

Set-Location ..

Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "  CORRECOES CONCLUIDAS!" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

Write-Host "`nAguardando 15 segundos para as mudancas propagarem..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

