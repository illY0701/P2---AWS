"""
Lambda Function - Process
Processa requisições POST e armazena dados no S3
"""
import json
import os
import boto3
from datetime import datetime
import logging

# Configurar logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Clientes AWS
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    """
    Handler principal da função Lambda
    Processa dados recebidos e armazena no S3
    """
    logger.info(f"Evento recebido: {json.dumps(event)}")
    
    try:
        # Obter variáveis de ambiente
        s3_bucket = os.environ.get('S3_BUCKET')
        project_name = os.environ.get('PROJECT_NAME', 'cloud-project')
        environment = os.environ.get('ENVIRONMENT', 'dev')
        
        # Parse do body
        if 'body' in event:
            body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
        else:
            body = event
        
        logger.info(f"Body processado: {body}")
        
        # Processar dados
        message = body.get('message', 'Sem mensagem')
        timestamp = datetime.utcnow().isoformat()
        
        # Preparar dados para salvar
        data = {
            'message': message,
            'timestamp': timestamp,
            'environment': environment,
            'project': project_name,
            'status': 'processed'
        }
        
        # Salvar no S3
        s3_key = f"processed/{datetime.utcnow().strftime('%Y/%m/%d')}/{timestamp}.json"
        
        s3_client.put_object(
            Bucket=s3_bucket,
            Key=s3_key,
            Body=json.dumps(data, indent=2),
            ContentType='application/json'
        )
        
        logger.info(f"Dados salvos em s3://{s3_bucket}/{s3_key}")
        
        # Resposta de sucesso
        response = {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST, OPTIONS'
            },
            'body': json.dumps({
                'success': True,
                'message': 'Dados processados com sucesso',
                'data': data,
                's3_location': f"s3://{s3_bucket}/{s3_key}"
            })
        }
        
        logger.info(f"Resposta: {response}")
        return response
        
    except Exception as e:
        logger.error(f"Erro ao processar: {str(e)}", exc_info=True)
        
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'success': False,
                'error': str(e),
                'message': 'Erro ao processar dados'
            })
        }



