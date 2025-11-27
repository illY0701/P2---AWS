#!/bin/bash

# ============================================================================
# Test Infrastructure Script
# Script para testar a infraestrutura AWS após deploy
# ============================================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Banner
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║            Teste de Infraestrutura AWS                       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Navegar para diretório Terraform
cd "$(dirname "$0")/../terraform" || exit 1

# Verificar se existe outputs.json
if [ ! -f "outputs.json" ]; then
    log_error "outputs.json não encontrado. Execute o deploy primeiro!"
    exit 1
fi

# Extrair informações dos outputs
EC2_IP=$(terraform output -raw ec2_public_ip 2>/dev/null || echo "")
API_URL=$(terraform output -raw api_gateway_url 2>/dev/null || echo "")
S3_BUCKET=$(terraform output -raw s3_assets_bucket_name 2>/dev/null || echo "")

echo "Testando componentes da infraestrutura..."
echo ""

# Teste 1: EC2
log_info "Testando EC2..."
if [ -n "$EC2_IP" ]; then
    if curl -s -o /dev/null -w "%{http_code}" "http://$EC2_IP" | grep -q "200"; then
        log_success "EC2 Web Server está respondendo"
    else
        log_error "EC2 Web Server não está respondendo"
    fi
else
    log_error "EC2 IP não encontrado"
fi

# Teste 2: API Gateway - Status
log_info "Testando API Gateway (/status)..."
if [ -n "$API_URL" ]; then
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/status")
    if [ "$STATUS_CODE" = "200" ]; then
        log_success "API Gateway /status está funcionando"
        echo "   Response:"
        curl -s "$API_URL/status" | python -m json.tool | head -20
    else
        log_error "API Gateway /status retornou $STATUS_CODE"
    fi
else
    log_error "API URL não encontrada"
fi

# Teste 3: API Gateway - Process
log_info "Testando API Gateway (/process)..."
if [ -n "$API_URL" ]; then
    RESPONSE=$(curl -s -X POST "$API_URL/process" \
        -H "Content-Type: application/json" \
        -d '{"message":"Test from script"}')
    
    if echo "$RESPONSE" | grep -q "success"; then
        log_success "API Gateway /process está funcionando"
        echo "   Response:"
        echo "$RESPONSE" | python -m json.tool | head -15
    else
        log_error "API Gateway /process falhou"
    fi
fi

# Teste 4: S3
log_info "Testando S3..."
if [ -n "$S3_BUCKET" ]; then
    if aws s3 ls "s3://$S3_BUCKET" &> /dev/null; then
        log_success "S3 Bucket está acessível"
        echo "   Conteúdo:"
        aws s3 ls "s3://$S3_BUCKET" --recursive | head -10
    else
        log_error "S3 Bucket não está acessível"
    fi
else
    log_error "S3 Bucket não encontrado"
fi

# Teste 5: RDS (verificar se está running)
log_info "Testando RDS..."
RDS_STATUS=$(aws rds describe-db-instances --query 'DBInstances[0].DBInstanceStatus' --output text 2>/dev/null || echo "")
if [ "$RDS_STATUS" = "available" ]; then
    log_success "RDS está disponível"
else
    log_error "RDS não está disponível (Status: $RDS_STATUS)"
fi

# Teste 6: ECS (verificar tasks)
log_info "Testando ECS..."
CLUSTER_NAME=$(terraform output -raw ecs_cluster_name 2>/dev/null || echo "")
if [ -n "$CLUSTER_NAME" ]; then
    TASK_COUNT=$(aws ecs describe-clusters --clusters "$CLUSTER_NAME" --query 'clusters[0].runningTasksCount' --output text 2>/dev/null || echo "0")
    if [ "$TASK_COUNT" -gt 0 ]; then
        log_success "ECS tem $TASK_COUNT task(s) em execução"
    else
        log_error "ECS não tem tasks em execução"
    fi
else
    log_error "ECS Cluster não encontrado"
fi

# Teste 7: Lambda (verificar funções)
log_info "Testando Lambda Functions..."
LAMBDA_COUNT=$(aws lambda list-functions --query 'length(Functions)' --output text 2>/dev/null || echo "0")
if [ "$LAMBDA_COUNT" -ge 3 ]; then
    log_success "Lambda Functions criadas ($LAMBDA_COUNT funções)"
else
    log_error "Lambda Functions incompletas ($LAMBDA_COUNT funções)"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                  Testes Concluídos                           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
log_info "Para mais detalhes, verifique o Console AWS"



