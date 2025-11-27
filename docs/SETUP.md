# Guia de Configuração Inicial

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

### 1. Terraform
```bash
# Windows (via Chocolatey)
choco install terraform

# macOS (via Homebrew)
brew install terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

Verifique a instalação:
```bash
terraform --version
```

### 2. AWS CLI
```bash
# Windows
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi

# macOS
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Verifique a instalação:
```bash
aws --version
```

### 3. Docker (para Grafana)
- Windows/Mac: [Docker Desktop](https://www.docker.com/products/docker-desktop)
- Linux: 
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### 4. Python 3.8+ (para testes)
```bash
python --version
pip install requests boto3
```

## 🔐 Configuração da AWS

### 1. Criar Conta AWS
1. Acesse [aws.amazon.com](https://aws.amazon.com)
2. Clique em "Create an AWS Account"
3. Siga as instruções (necessário cartão de crédito)

### 2. Criar IAM User
1. Acesse o Console AWS
2. Vá em **IAM** → **Users** → **Add Users**
3. Nome: `terraform-user`
4. Tipo de acesso: **Programmatic access**
5. Permissões: **AdministratorAccess** (para desenvolvimento)
6. Salve as credenciais (Access Key ID e Secret Access Key)

### 3. Configurar AWS CLI
```bash
aws configure
```

Insira:
- **AWS Access Key ID**: [sua access key]
- **AWS Secret Access Key**: [sua secret key]
- **Default region**: `us-east-1`
- **Default output format**: `json`

Teste a configuração:
```bash
aws sts get-caller-identity
```

## 📁 Configuração do Projeto

### 1. Clonar/Baixar o Projeto
```bash
cd "P2 - Sexta"
```

### 2. Configurar Variáveis do Terraform
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edite `terraform.tfvars`:
```hcl
aws_region   = "us-east-1"
project_name = "seu-projeto"
owner        = "Seu Nome"

# IMPORTANTE: Mude a senha do banco de dados!
db_password  = "SuaSenhaSegura123!"
```

### 3. Revisar Custos Estimados
Antes de fazer deploy, revise os custos no arquivo `architecture/diagram.md`:
- Estimativa: ~$60-70/mês
- Componentes que mais custam: RDS, ECS, NAT Gateway

💡 **Dica**: Use o [AWS Pricing Calculator](https://calculator.aws) para estimar custos específicos.

## ⚙️ Variáveis de Ambiente (Opcional)

### Para CI/CD ou automação:
```bash
# Linux/Mac
export AWS_ACCESS_KEY_ID="sua-key"
export AWS_SECRET_ACCESS_KEY="sua-secret"
export TF_VAR_db_password="senha-segura"

# Windows PowerShell
$env:AWS_ACCESS_KEY_ID="sua-key"
$env:AWS_SECRET_ACCESS_KEY="sua-secret"
$env:TF_VAR_db_password="senha-segura"
```

## 🔒 Boas Práticas de Segurança

### 1. Nunca commite credenciais
Adicione ao `.gitignore`:
```
terraform.tfvars
*.pem
*.key
.env
credentials
```

### 2. Use Secrets Manager (Produção)
Em produção, considere usar:
- AWS Secrets Manager para senhas
- AWS Parameter Store para configurações
- IAM Roles em vez de access keys

### 3. Habilite MFA
1. Vá em **IAM** → **Users** → seu usuário
2. **Security credentials** → **Assign MFA device**

### 4. Configure AWS Budget Alerts
1. Vá em **Billing** → **Budgets**
2. Crie um budget de $50/mês
3. Configure alertas em 80% e 100%

## 🚀 Próximos Passos

Após a configuração inicial, consulte:
- [DEPLOYMENT.md](./DEPLOYMENT.md) - Como fazer deploy
- [MONITORING.md](./MONITORING.md) - Como configurar monitoramento

## ❓ Troubleshooting

### Erro: "Unable to locate credentials"
```bash
# Verifique se as credenciais estão configuradas
aws configure list

# Teste a conexão
aws sts get-caller-identity
```

### Erro: "Access Denied"
- Verifique se o IAM user tem as permissões necessárias
- Confirme se as credenciais estão corretas

### Erro: Terraform "backend initialization required"
```bash
cd terraform
terraform init
```

### Erro: "Resource already exists"
```bash
# Importe o recurso existente
terraform import <resource_type>.<name> <id>

# Ou destrua e recrie
terraform destroy
terraform apply
```

## 📞 Suporte

- **AWS Documentation**: https://docs.aws.amazon.com
- **Terraform Documentation**: https://www.terraform.io/docs
- **AWS Free Tier**: https://aws.amazon.com/free

## ✅ Checklist de Configuração

- [ ] Terraform instalado e verificado
- [ ] AWS CLI instalado e configurado
- [ ] Docker instalado (para Grafana)
- [ ] Python instalado (para testes)
- [ ] Conta AWS criada
- [ ] IAM user criado com permissões
- [ ] Credenciais AWS configuradas
- [ ] Arquivo terraform.tfvars configurado
- [ ] Senha do banco de dados alterada
- [ ] Budget alerts configurados
- [ ] .gitignore configurado

Após completar esta checklist, você está pronto para fazer o deploy!



