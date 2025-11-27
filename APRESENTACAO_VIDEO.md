# 🎬 APRESENTAÇÃO EM VÍDEO - Guia Completo

## 📋 TUDO QUE VOCÊ PRECISA PARA GRAVAR O VÍDEO

---

## ⏱️ ROTEIRO DO VÍDEO (3 minutos)

### 🎯 INTRODUÇÃO (0:00 - 0:30)

**[Mostrar na tela]**
- Repositório GitHub aberto
- Estrutura de pastas do projeto

**[Falar]**
> "Olá! Sou [SEU NOME] e vou apresentar o projeto da Avaliação 02 de Cloud Computing."
> 
> "Implementei uma arquitetura completa na AWS com TODOS os serviços pedidos:"
> - EC2 para servidor web
> - RDS para banco de dados PostgreSQL
> - S3 para armazenamento de objetos
> - ECS para containers Docker
> - Lambda para funções serverless
> - API Gateway para endpoints REST
> - E CloudWatch + Grafana para monitoramento completo

**[Destacar]**
- "Tudo foi criado com Terraform usando apenas init, plan e apply"

---

### 📊 PARTE 1: DIAGRAMA DE ARQUITETURA (0:30 - 1:00)

**[Mostrar na tela]**
- Arquivo: `architecture/diagram.md`
- Diagrama completo da arquitetura

**[Falar]**
> "Aqui está o diagrama completo da arquitetura:"

**[Apontar no diagrama]**
1. **VPC com subnets públicas e privadas** - "Configurei uma VPC com 4 subnets em multi-AZ"
2. **EC2 na subnet pública** - "Instância EC2 com Nginx rodando na subnet pública"
3. **RDS na subnet privada** - "PostgreSQL em Multi-AZ para alta disponibilidade"
4. **ECS com Fargate** - "Containers rodando no ECS Fargate com auto-scaling"
5. **Lambda + API Gateway** - "3 funções Lambda expostas via API Gateway REST"
6. **S3 Buckets** - "2 buckets S3 para assets e logs, com versionamento e encryption"
7. **CloudWatch** - "Monitoramento completo com logs e alarmes de todos os serviços"

---

### 🛠️ PARTE 2: TERRAFORM (1:00 - 1:45)

**[Mostrar na tela]**
- Terminal aberto no diretório `terraform/`
- Estrutura de módulos

**[Falar]**
> "Todo o deploy é feito com Terraform de forma automatizada"

**[Executar comandos]**
```powershell
cd terraform
```

**[Mostrar]**
- Estrutura de módulos organizados:
  - vpc/, ec2/, rds/, s3/, ecs/, lambda/, api-gateway/, monitoring/

**[Falar]**
> "A infraestrutura completa é criada com apenas 3 comandos:"

```powershell
terraform init
terraform plan
terraform apply
```

**[Mostrar outputs]**
```powershell
terraform output
```

> "E aqui está o resultado: 61 recursos criados com sucesso!"

---

### 🚀 PARTE 3: DEMONSTRAÇÃO (1:45 - 2:20)

**[Mostrar na tela]**
- Navegador com múltiplas abas
- Console AWS aberto

**[Testar EC2]**
- Acessar: http://3.90.12.194
> "Aqui está o servidor web EC2 rodando Nginx"

**[Testar Lambda via API Gateway]**
- Acessar: https://icxeef1il7.execute-api.us-east-1.amazonaws.com/prod/status
> "Lambda funcionando via API Gateway"

**[Mostrar Console AWS]**
- Abrir CloudWatch Dashboard
> "Dashboard do CloudWatch com todas as métricas em tempo real"

**[Mostrar serviços no Console AWS]**
- EC2: Instância running
- RDS: Database available
- S3: Buckets criados
- ECS: Cluster com tasks rodando
- Lambda: 3 funções ativas
- API Gateway: API deployada

---

### 📈 PARTE 4: GRAFANA (2:20 - 2:45)

**[Mostrar na tela]**
- Arquivo: `grafana/dashboards/overview-dashboard.json`

**[Falar]**
> "E aqui está o dashboard do Grafana configurado para monitorar todos os serviços"

**[Mostrar no código]**
- Painel de CPU do EC2
- Painel de CPU do RDS
- Painel de erros do Lambda
- Painel de requests do API Gateway
- Painel de recursos do ECS

**[Explicar]**
> "O dashboard está configurado para coletar métricas do CloudWatch e exibir:"
> - CPU e memória de EC2 e ECS
> - Conexões e latência do RDS
> - Invocações e erros das Lambdas
> - Requests do API Gateway

---

### ✅ CONCLUSÃO (2:45 - 3:00)

**[Mostrar na tela]**
- Resumo visual de todos os serviços

**[Falar]**
> "Resumindo: implementei com sucesso:"
> - ✓ Arquitetura completa com todos os 6 serviços AWS
> - ✓ Scripts Terraform funcionando com init, plan e apply
> - ✓ Dashboards Grafana para monitoramento completo
> - ✓ Alta disponibilidade com Multi-AZ
> - ✓ Segurança com encryption e IAM roles
> - ✓ Monitoramento completo com CloudWatch

> "Todo o código está disponível no GitHub e a infraestrutura está rodando na AWS"

**[Mostrar]**
- Link do GitHub
- URLs dos serviços

> "Obrigado!"

---

## 🖥️ COMANDOS PARA EXECUTAR NO VÍDEO

### Configurar Ambiente

```powershell
# Adicionar Terraform ao PATH
$env:Path += ";C:\terraform"

# Navegar para o projeto
cd "C:\Users\illib\Downloads\P2 - Sexta\terraform"
```

### Mostrar Terraform Funcionando

```powershell
# Ver versão
terraform --version

# Ver outputs (mostra todos os serviços criados)
terraform output

# Ver estrutura de módulos
Get-ChildItem modules | Select-Object Name
```

### Mostrar Diagrama

```powershell
cd ..
Get-Content architecture\diagram.md
```

### Mostrar Dashboard Grafana

```powershell
Get-Content grafana\dashboards\overview-dashboard.json | Select-Object -First 50
```

---

## 🌐 URLs IMPORTANTES

### Serviços para Testar:

**EC2 Web Server:**
```
http://3.90.12.194
```

**API Gateway + Lambda:**
```
Status:  https://icxeef1il7.execute-api.us-east-1.amazonaws.com/prod/status
Data:    https://icxeef1il7.execute-api.us-east-1.amazonaws.com/prod/data
Process: https://icxeef1il7.execute-api.us-east-1.amazonaws.com/prod/process
```

### Console AWS - Serviços:

**EC2:**
```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:
```

**RDS:**
```
https://console.aws.amazon.com/rds/home?region=us-east-1#databases:
```

**S3:**
```
https://s3.console.aws.amazon.com/s3/buckets?region=us-east-1
```

**ECS:**
```
https://console.aws.amazon.com/ecs/home?region=us-east-1#/clusters
```

**Lambda:**
```
https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions
```

**API Gateway:**
```
https://console.aws.amazon.com/apigateway/home?region=us-east-1#/apis
```

**CloudWatch Dashboard:**
```
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards
```

---

## 📝 CHECKLIST PRÉ-GRAVAÇÃO

### Preparação Técnica:
- [ ] Terraform instalado e funcionando
- [ ] Abrir arquivo `architecture/diagram.md`
- [ ] Terminal no diretório `terraform/`
- [ ] Navegador com abas abertas:
  - [ ] http://3.90.12.194
  - [ ] https://icxeef1il7.execute-api.us-east-1.amazonaws.com/prod/status
  - [ ] Console AWS CloudWatch
- [ ] Arquivo `grafana/dashboards/overview-dashboard.json` aberto
- [ ] Console AWS aberto com todos os serviços

### Durante a Gravação:
- [ ] Falar com clareza e pausadamente
- [ ] Mostrar o rosto ou usar voz clara
- [ ] Apontar para elementos importantes na tela
- [ ] NÃO passar de 3 minutos
- [ ] Terminar com confiança mostrando que tudo funciona

### Após Gravação:
- [ ] Revisar o vídeo
- [ ] Adicionar legenda com principais pontos (opcional)
- [ ] Fazer upload no YouTube
- [ ] Configurar como não listado ou público
- [ ] Copiar o link

---

## 🎥 DICAS DE GRAVAÇÃO

### Software Recomendado:
- **Windows**: OBS Studio (gratuito)
- **Mac**: QuickTime / OBS Studio
- **Online**: Loom (gratuito até 5 min)

### Configurações:
- **Resolução**: 1080p (1920x1080)
- **FPS**: 30 ou 60
- **Audio**: Microfone externo se possível
- **Zoom**: Use zoom para destacar partes importantes

### Durante a Gravação:
1. **Velocidade**: Fale mais devagar do que o normal
2. **Pausas**: Faça pausas entre cada seção
3. **Cursor**: Use o cursor para apontar elementos importantes
4. **Transições**: Anuncie quando mudar de tela/tópico

---

## 📤 UPLOAD NO YOUTUBE

### Configurações do Vídeo:
- **Título**: "Avaliação 02 - Cloud Computing AWS - [SEU NOME]"
- **Descrição**:
```
Projeto da Avaliação 02 - Cloud Computing (AWS)

Implementação completa de arquitetura AWS com:
✓ EC2 (Web Server)
✓ RDS (PostgreSQL)
✓ S3 (Storage)
✓ ECS (Containers)
✓ Lambda (Serverless)
✓ API Gateway (REST API)
✓ CloudWatch + Grafana (Monitoring)

Toda infraestrutura criada com Terraform (init, plan, apply)

Repositório GitHub: [SEU LINK]

Professor: Cesar Druwg
Curso: Cloud Computing
```

- **Tags**: AWS, Cloud Computing, Terraform, EC2, RDS, S3, Lambda, API Gateway, ECS, CloudWatch, Grafana
- **Visibilidade**: Não Listado (ou Público se preferir)
- **Miniatura**: Print da arquitetura ou dashboard

---

## ✅ CHECKLIST FINAL

- [ ] Vídeo gravado (máximo 3 minutos)
- [ ] Vídeo revisado
- [ ] Upload no YouTube completo
- [ ] Link do YouTube copiado
- [ ] GitHub atualizado com todos os arquivos
- [ ] Link do GitHub copiado
- [ ] URLs dos serviços AWS anotadas
- [ ] Formulário do professor preenchido

---

## 🎯 RESUMO: O QUE MOSTRAR NO VÍDEO

1. ✅ **Estrutura do projeto** - Mostrar organização
2. ✅ **Diagrama de arquitetura** - Explicar os 6 serviços
3. ✅ **Terraform funcionando** - Mostrar outputs e módulos
4. ✅ **Console AWS** - Mostrar serviços rodando
5. ✅ **Dashboard Grafana** - Mostrar código JSON
6. ✅ **Conclusão** - Resumo do que foi feito

---

**BOA GRAVAÇÃO! 🎬**

Lembre-se: seja confiante, mostre o trabalho com orgulho e demonstre que tudo funciona! 🚀

