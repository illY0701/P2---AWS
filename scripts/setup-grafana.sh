#!/bin/bash

# ============================================================================
# Setup Grafana Script
# Script para configurar e iniciar Grafana com Docker
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
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Banner
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║              Setup Grafana - Monitoramento AWS               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    log_error "Docker não está instalado!"
    log_info "Instale o Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Verificar se Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose não está instalado!"
    log_info "Instale o Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

# Navegar para diretório Grafana
cd "$(dirname "$0")/../grafana" || exit 1

# Verificar credenciais AWS
log_info "Verificando credenciais AWS..."
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    log_warning "Variáveis de ambiente AWS não configuradas!"
    log_info "Exportando credenciais do AWS CLI..."
    
    export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
    export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
    
    if [ -z "$AWS_ACCESS_KEY_ID" ]; then
        log_error "Não foi possível obter credenciais AWS!"
        log_info "Execute: aws configure"
        exit 1
    fi
fi
log_success "Credenciais AWS configuradas"

# Parar container existente se houver
log_info "Verificando containers existentes..."
if docker ps -a | grep -q "grafana-cloud-monitoring"; then
    log_info "Parando container existente..."
    docker-compose down
    log_success "Container removido"
fi

# Iniciar Grafana
log_info "Iniciando Grafana..."
docker-compose -f grafana-config.yml up -d

# Aguardar Grafana iniciar
log_info "Aguardando Grafana iniciar..."
sleep 10

# Verificar se está rodando
if docker ps | grep -q "grafana-cloud-monitoring"; then
    log_success "Grafana está rodando!"
else
    log_error "Falha ao iniciar Grafana"
    docker-compose logs
    exit 1
fi

# Informações de acesso
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                Grafana Configurado!                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
log_info "Acesse o Grafana em: http://localhost:3000"
log_info "Usuário: admin"
log_info "Senha: admin123"
echo ""
log_info "Dashboards disponíveis:"
log_success "  - AWS Infrastructure Overview"
log_success "  - EC2 Monitoring"
log_success "  - RDS Monitoring"
log_success "  - ECS Monitoring"
log_success "  - Lambda Monitoring"
echo ""
log_info "Para parar o Grafana: docker-compose -f grafana-config.yml down"
log_info "Para ver logs: docker-compose -f grafana-config.yml logs -f"
echo ""
log_success "Setup concluído! 🎉"



