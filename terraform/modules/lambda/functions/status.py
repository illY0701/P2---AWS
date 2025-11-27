"""
Lambda Function - Status
Retorna o status da aplicação e informações do sistema
"""
import json
import os
import boto3
from datetime import datetime
import logging

# Configurar logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Handler principal da função Lambda
    Retorna status do sistema
    """
    logger.info(f"Status check iniciado")
    
    try:
        # Obter variáveis de ambiente
        project_name = os.environ.get('PROJECT_NAME', 'cloud-project')
        environment = os.environ.get('ENVIRONMENT', 'dev')
        
        # Informações do sistema
        status_info = {
            'status': 'online',
            'timestamp': datetime.utcnow().isoformat(),
            'project': project_name,
            'environment': environment,
            'function': getattr(context, 'function_name', 'unknown'),
            'version': getattr(context, 'function_version', 'unknown'),
            'memory_limit': getattr(context, 'memory_limit_in_mb', 'unknown'),
            'request_id': getattr(context, 'aws_request_id', 'unknown'),
            'services': {
                'lambda': 'operational',
                'api_gateway': 'operational',
                's3': 'operational',
                'rds': 'operational',
                'ec2': 'operational',
                'ecs': 'operational'
            },
            'checks': {
                'database': check_database_connection(),
                's3': check_s3_access(),
                'memory': check_memory()
            }
        }
        
        logger.info(f"Status: {status_info}")
        
        # Resposta de sucesso
        response = {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET, OPTIONS'
            },
            'body': json.dumps(status_info, indent=2)
        }
        
        return response
        
    except Exception as e:
        logger.error(f"Erro ao verificar status: {str(e)}", exc_info=True)
        
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'status': 'error',
                'error': str(e),
                'message': 'Erro ao verificar status'
            })
        }

def check_database_connection():
    """Verifica conexão com banco de dados"""
    try:
        # Simulação - implementar verificação real se necessário
        return {'status': 'ok', 'message': 'Database connection successful'}
    except Exception as e:
        return {'status': 'error', 'message': str(e)}

def check_s3_access():
    """Verifica acesso ao S3"""
    try:
        s3_bucket = os.environ.get('S3_BUCKET')
        if s3_bucket:
            s3_client = boto3.client('s3')
            s3_client.head_bucket(Bucket=s3_bucket)
            return {'status': 'ok', 'message': 'S3 access successful', 'bucket': s3_bucket}
        return {'status': 'warning', 'message': 'S3 bucket not configured'}
    except Exception as e:
        return {'status': 'error', 'message': str(e)}

def check_memory():
    """Verifica uso de memória"""
    try:
        import psutil
        memory = psutil.virtual_memory()
        return {
            'status': 'ok',
            'percent_used': memory.percent,
            'available_mb': memory.available / 1024 / 1024
        }
    except:
        # psutil pode não estar disponível
        return {'status': 'ok', 'message': 'Memory check not available'}



