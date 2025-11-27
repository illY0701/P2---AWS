# Guia de Monitoramento

## 📊 Visão Geral

Este projeto implementa monitoramento completo usando:
- **CloudWatch**: Métricas e logs da AWS
- **Grafana**: Dashboards visuais
- **CloudWatch Alarms**: Alertas automáticos

## 🚀 Setup Rápido do Grafana

### 1. Iniciar Grafana
```bash
# Script automatizado
bash scripts/setup-grafana.sh

# Ou manualmente
cd grafana
docker-compose -f grafana-config.yml up -d
```

### 2. Acessar Grafana
- **URL**: http://localhost:3000
- **Usuário**: `admin`
- **Senha**: `admin123`

### 3. Verificar Dashboards
Os dashboards são carregados automaticamente:
- AWS Infrastructure Overview
- EC2 Monitoring
- RDS Monitoring
- ECS Monitoring
- Lambda Monitoring

## 📈 CloudWatch

### Métricas Coletadas

#### EC2
```bash
# Ver métricas via CLI
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=[INSTANCE_ID] \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

**Métricas disponíveis**:
- CPUUtilization
- NetworkIn/Out
- DiskReadBytes/WriteBytes
- StatusCheckFailed
- MemoryUtilization (via CloudWatch Agent)

#### RDS
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBInstanceIdentifier,Value=[DB_ID] \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

**Métricas disponíveis**:
- CPUUtilization
- DatabaseConnections
- ReadLatency/WriteLatency
- FreeStorageSpace
- FreeableMemory

#### Lambda
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=[FUNCTION_NAME] \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

**Métricas disponíveis**:
- Invocations
- Errors
- Throttles
- Duration
- ConcurrentExecutions

#### ECS
**Métricas disponíveis**:
- CPUUtilization
- MemoryUtilization
- RunningTaskCount

#### API Gateway
**Métricas disponíveis**:
- Count (total requests)
- 4XXError / 5XXError
- Latency
- IntegrationLatency

### Logs no CloudWatch

#### Ver Logs
```bash
# EC2 Nginx logs
aws logs tail /aws/ec2/[PROJECT]/nginx --follow

# Lambda logs
aws logs tail /aws/lambda/[PROJECT]-process --follow

# ECS logs
aws logs tail /ecs/[PROJECT] --follow

# API Gateway logs
aws logs tail /aws/api-gateway/[PROJECT] --follow
```

#### Filtrar Logs
```bash
# Buscar erros
aws logs filter-log-events \
  --log-group-name /aws/lambda/[FUNCTION] \
  --filter-pattern "ERROR"

# Buscar por período
aws logs filter-log-events \
  --log-group-name /aws/ec2/[PROJECT]/nginx \
  --start-time $(date -d '1 hour ago' +%s)000 \
  --end-time $(date +%s)000
```

### CloudWatch Alarms

#### Alarmes Configurados

1. **EC2 CPU High** (> 80%)
2. **RDS CPU High** (> 80%)
3. **RDS Connections High** (> 80)
4. **RDS Storage Low** (< 5GB)
5. **Lambda Errors** (> 5 errors)
6. **Lambda Duration High** (> 25s)
7. **ECS CPU High** (> 80%)
8. **ECS Memory High** (> 80%)

#### Ver Alarmes
```bash
# Listar todos os alarmes
aws cloudwatch describe-alarms

# Ver alarmes em estado ALARM
aws cloudwatch describe-alarms \
  --state-value ALARM

# Ver histórico de um alarme
aws cloudwatch describe-alarm-history \
  --alarm-name [PROJECT]-ec2-cpu-high
```

#### Criar Alarme Personalizado
```bash
aws cloudwatch put-metric-alarm \
  --alarm-name my-custom-alarm \
  --alarm-description "Custom alarm" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 90 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2
```

## 📊 Grafana Dashboards

### Dashboard: AWS Infrastructure Overview

**Painéis inclusos**:
1. EC2 CPU Utilization (line chart)
2. RDS CPU Utilization (line chart)
3. Lambda Errors (gauge)
4. API Gateway Requests (stat)
5. ECS Resource Utilization (line chart)

### Dashboard: EC2 Monitoring

**Métricas**:
- CPU Usage (%)
- Network In/Out (bytes)
- Disk I/O (bytes)
- Memory Usage (%)

**Queries CloudWatch**:
```sql
-- CPU
SELECT AVG(CPUUtilization) 
FROM SCHEMA("AWS/EC2", InstanceId)

-- Network
SELECT SUM(NetworkIn), SUM(NetworkOut)
FROM SCHEMA("AWS/EC2", InstanceId)
```

### Dashboard: RDS Monitoring

**Métricas**:
- CPU Utilization
- Database Connections
- Read/Write Latency
- Free Storage Space
- Freeable Memory

### Dashboard: Lambda Monitoring

**Métricas**:
- Total Invocations
- Error Count
- Throttles
- Average Duration
- Concurrent Executions

### Dashboard: ECS Monitoring

**Métricas**:
- CPU Utilization
- Memory Utilization
- Running Task Count
- Network Throughput

### Personalizar Dashboards

#### Via Interface Grafana:
1. Acesse http://localhost:3000
2. Clique em dashboard desejado
3. Clique em ⚙️ (Settings) → Add Panel
4. Configure query CloudWatch
5. Ajuste visualização
6. Save dashboard

#### Via JSON:
```bash
# Editar arquivo JSON
nano grafana/dashboards/overview-dashboard.json

# Reiniciar Grafana
docker-compose -f grafana/grafana-config.yml restart
```

## 🎯 Exemplo: Dashboard Customizado

### Criar Novo Dashboard

1. **Via Grafana UI**:
   - Dashboard → New Dashboard → Add Panel
   - Data Source: CloudWatch
   - Query:
     ```
     Namespace: AWS/Lambda
     Metric: Duration
     Stat: Average
     Dimensions: FunctionName
     ```

2. **Via JSON** (grafana/dashboards/custom.json):
```json
{
  "title": "Custom Dashboard",
  "panels": [
    {
      "targets": [
        {
          "namespace": "AWS/Lambda",
          "metricName": "Duration",
          "statistics": ["Average"],
          "dimensions": {
            "FunctionName": ["*"]
          }
        }
      ]
    }
  ]
}
```

## 🔔 Configurar Alertas

### No CloudWatch

#### Via Console:
1. CloudWatch → Alarms → Create Alarm
2. Select Metric (ex: Lambda Errors)
3. Conditions: Threshold > 5
4. Actions: SNS Topic
5. Create alarm

#### Via CLI:
```bash
# Criar SNS topic
aws sns create-topic --name alerts

# Subscrever email
aws sns subscribe \
  --topic-arn arn:aws:sns:region:account:alerts \
  --protocol email \
  --notification-endpoint seu@email.com

# Criar alarme
aws cloudwatch put-metric-alarm \
  --alarm-name lambda-errors-high \
  --alarm-description "Lambda has too many errors" \
  --actions-enabled \
  --alarm-actions arn:aws:sns:region:account:alerts \
  --metric-name Errors \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --evaluation-periods 1 \
  --threshold 5 \
  --comparison-operator GreaterThanThreshold
```

### No Grafana

1. Edit Panel → Alert
2. Conditions:
   - WHEN: avg()
   - OF: query(A, 5m, now)
   - IS ABOVE: 80
3. Notifications: Add notification channel
4. Save

## 📱 Notification Channels

### Email
```bash
# SNS Topic
aws sns create-topic --name email-alerts

# Subscribe
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:123456:email-alerts \
  --protocol email \
  --notification-endpoint seu@email.com
```

### Slack
1. Criar Slack Webhook
2. Grafana → Alerting → Notification Channels
3. Type: Slack
4. Webhook URL: [seu webhook]

### SMS
```bash
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:123456:alerts \
  --protocol sms \
  --notification-endpoint +5511999999999
```

## 📊 Métricas Customizadas

### Enviar Métrica Custom
```python
import boto3

cloudwatch = boto3.client('cloudwatch')

cloudwatch.put_metric_data(
    Namespace='MyApp/Custom',
    MetricData=[
        {
            'MetricName': 'CustomMetric',
            'Value': 123.0,
            'Unit': 'Count',
            'Timestamp': datetime.utcnow()
        }
    ]
)
```

### Via CloudWatch Agent
```json
{
  "metrics": {
    "namespace": "MyApp/Custom",
    "metrics_collected": {
      "statsd": {
        "service_address": ":8125",
        "metrics_collection_interval": 60,
        "metrics_aggregation_interval": 300
      }
    }
  }
}
```

## 🔍 Logs Insights

### Queries Úteis

#### Top 10 endpoints mais chamados:
```sql
fields @timestamp, @message
| filter @message like /GET|POST/
| stats count() by @message
| sort count desc
| limit 10
```

#### Erros Lambda:
```sql
fields @timestamp, @message
| filter @type = "ERROR"
| sort @timestamp desc
| limit 20
```

#### Latência API:
```sql
fields @timestamp, latency
| filter @type = "REQUEST"
| stats avg(latency), max(latency), min(latency)
```

## 💰 Custos de Monitoramento

### CloudWatch
- **Métricas**: $0.30 por métrica/mês
- **Logs**: $0.50 por GB ingerido
- **Dashboards**: $3 por dashboard/mês
- **Alarms**: $0.10 por alarme/mês

### Grafana (Self-hosted)
- **Grátis** (rodando localmente)
- Custo apenas de computação se hospedar na AWS

### Estimativa Mensal
- CloudWatch: ~$10-20
- Logs: ~$5-10
- Total: ~$15-30/mês

## 📋 Checklist de Monitoramento

- [ ] CloudWatch logs habilitado
- [ ] CloudWatch métricas coletando
- [ ] Alarmes configurados
- [ ] SNS topics criados
- [ ] Email notifications testadas
- [ ] Grafana rodando
- [ ] Dashboards carregados
- [ ] Data sources configurados
- [ ] Panels mostrando dados
- [ ] Alertas do Grafana configurados

## 🎥 Para o Vídeo

### Pontos a Demonstrar:
1. ✅ Dashboard CloudWatch com todas as métricas
2. ✅ Logs em tempo real
3. ✅ Grafana com dashboards customizados
4. ✅ Alarmes configurados
5. ✅ Métricas de cada serviço (EC2, RDS, Lambda, etc)

### Script para Demo:
1. Abrir CloudWatch dashboard
2. Mostrar métricas de EC2, RDS, Lambda
3. Mostrar logs em tempo real
4. Abrir Grafana
5. Navegar pelos dashboards
6. Mostrar painéis responsivos

## 📞 Troubleshooting

### Grafana não mostra dados
```bash
# Verificar credentials AWS
docker exec grafana-cloud-monitoring env | grep AWS

# Restart com logs
docker-compose -f grafana-config.yml down
docker-compose -f grafana-config.yml up
```

### CloudWatch Agent não enviando métricas
```bash
# Check agent status
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a query -m ec2 -c default -s

# Restart agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a stop -m ec2 -c default
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a start -m ec2 -c default
```

### Métricas atrasadas
- CloudWatch tem delay de ~5 minutos
- Métricas detalhadas têm menor delay
- Use refresh de 1 minuto no Grafana

## 🎯 Melhores Práticas

1. **Retention**: Configure retenção apropriada (7-30 dias)
2. **Sampling**: Use períodos adequados (300s para a maioria)
3. **Alertas**: Configure apenas alertas acionáveis
4. **Dashboards**: Mantenha simples e focados
5. **Custos**: Monitore uso do CloudWatch regularmente

Pronto! Seu monitoramento está completo e pronto para demonstração! 🎉



