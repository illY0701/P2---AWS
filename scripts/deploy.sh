#!/bin/bash

# ============================================================================
# Deploy Script - Terraform Infrastructure
# Script para fazer deploy completo da infraestrutura AWS
# ============================================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções auxiliares
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
echo "║         Deploy - Infraestrutura AWS com Terraform           ║"
echo "║              Avaliação 02 - Cloud Computing                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Verificar se o Terraform está instalado
if ! command -v terraform &> /dev/null; then
    log_error "Terraform não está instalado!"
    log_info "Instale o Terraform: https://www.terraform.io/downloads"
    exit 1
fi

# Verificar se o AWS CLI está instalado
if ! command -v aws &> /dev/null; then
    log_error "AWS CLI não está instalado!"
    log_info "Instale o AWS CLI: https://aws.amazon.com/cli/"
    exit 1
fi

# Verificar credenciais AWS
log_info "Verificando credenciais AWS..."
if ! aws sts get-caller-identity &> /dev/null; then
    log_error "Credenciais AWS não configuradas!"
    log_info "Execute: aws configure"
    exit 1
fi
log_success "Credenciais AWS verificadas"

# Navegar para diretório Terraform
cd "$(dirname "$0")/../terraform" || exit 1

# Verificar se arquivo terraform.tfvars existe
if [ ! -f "terraform.tfvars" ]; then
    log_warning "Arquivo terraform.tfvars não encontrado!"
    log_info "Criando a partir do exemplo..."
    cp terraform.tfvars.example terraform.tfvars
    log_warning "IMPORTANTE: Edite terraform.tfvars com suas configurações!"
    read -p "Pressione Enter para continuar após editar o arquivo..."
fi

# Terraform Init
log_info "Inicializando Terraform..."
terraform init -upgrade
log_success "Terraform inicializado"

# Terraform Validate
log_info "Validando configurações Terraform..."
terraform validate
log_success "Configurações validadas"

# Terraform Plan
log_info "Criando plano de execução..."
terraform plan -out=tfplan
log_success "Plano criado"

# Confirmar deploy
echo ""
log_warning "Você está prestes a criar recursos na AWS que podem gerar custos!"
read -p "Deseja continuar com o deploy? (sim/nao): " confirm

if [ "$confirm" != "sim" ]; then
    log_info "Deploy cancelado pelo usuário"
    exit 0
fi

# Terraform Apply
log_info "Aplicando infraestrutura..."
terraform apply tfplan
log_success "Infraestrutura criada com sucesso!"

# Salvar outputs
log_info "Salvando outputs..."
terraform output -json > outputs.json
log_success "Outputs salvos em outputs.json"

# Mostrar resumo
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    Deploy Concluído!                         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Exibir informações importantes
log_info "Informações da infraestrutura:"
terraform output connection_summary

echo ""
log_success "Para destruir a infraestrutura, execute: bash scripts/destroy.sh"
log_info "Para testar a infraestrutura, execute: python tests/infrastructure-test.py"
log_info "Para configurar Grafana, execute: bash scripts/setup-grafana.sh"

# Remover arquivo de plano
rm -f tfplan

log_success "Deploy finalizado com sucesso! 🚀"



