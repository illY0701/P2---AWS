#!/bin/bash

# ============================================================================
# Destroy Script - Terraform Infrastructure
# Script para destruir toda a infraestrutura AWS
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
echo "║          Destroy - Infraestrutura AWS com Terraform         ║"
echo "║              Avaliação 02 - Cloud Computing                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Navegar para diretório Terraform
cd "$(dirname "$0")/../terraform" || exit 1

# Confirmar destroy
log_warning "ATENÇÃO! Você está prestes a DESTRUIR toda a infraestrutura AWS!"
log_warning "Esta ação é IRREVERSÍVEL e todos os dados serão perdidos!"
echo ""
read -p "Digite 'DESTRUIR' para confirmar: " confirm

if [ "$confirm" != "DESTRUIR" ]; then
    log_info "Operação cancelada pelo usuário"
    exit 0
fi

# Segunda confirmação
log_warning "Última chance para cancelar!"
read -p "Tem certeza absoluta? (sim/nao): " confirm2

if [ "$confirm2" != "sim" ]; then
    log_info "Operação cancelada pelo usuário"
    exit 0
fi

# Terraform Destroy
log_info "Destruindo infraestrutura..."
terraform destroy -auto-approve

log_success "Infraestrutura destruída com sucesso! ✓"

# Limpar arquivos
log_info "Limpando arquivos..."
rm -f tfplan
rm -f outputs.json
rm -rf .terraform
rm -f .terraform.lock.hcl
rm -f terraform.tfstate
rm -f terraform.tfstate.backup

log_success "Limpeza concluída! ✓"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║              Infraestrutura Removida                         ║"
echo "╚══════════════════════════════════════════════════════════════╝"



