"""
Lambda Function - Data
Retorna dados armazenados no S3
"""
import json
import os
import boto3
from datetime import datetime, timedelta
import logging

# Configurar logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Clientes AWS
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    """
    Handler principal da função Lambda
    Lista e retorna dados do S3
    """
    logger.info(f"Data retrieval iniciado")
    
    try:
        # Obter variáveis de ambiente
        s3_bucket = os.environ.get('S3_BUCKET')
        project_name = os.environ.get('PROJECT_NAME', 'cloud-project')
        environment = os.environ.get('ENVIRONMENT', 'dev')
        
        # Parse query parameters
        params = event.get('queryStringParameters', {}) or {}
        limit = int(params.get('limit', 10))
        prefix = params.get('prefix', 'processed/')
        
        logger.info(f"Buscando dados em s3://{s3_bucket}/{prefix} (limit: {limit})")
        
        # Listar objetos do S3
        response = s3_client.list_objects_v2(
            Bucket=s3_bucket,
            Prefix=prefix,
            MaxKeys=limit
        )
        
        # Processar resultados
        files = []
        if 'Contents' in response:
            for obj in response['Contents']:
                files.append({
                    'key': obj['Key'],
                    'size': obj['Size'],
                    'last_modified': obj['LastModified'].isoformat(),
                    'url': f"s3://{s3_bucket}/{obj['Key']}"
                })
        
        # Estatísticas
        stats = {
            'total_files': len(files),
            'bucket': s3_bucket,
            'prefix': prefix,
            'limit': limit
        }
        
        # Resposta
        data = {
            'success': True,
            'timestamp': datetime.utcnow().isoformat(),
            'project': project_name,
            'environment': environment,
            'stats': stats,
            'files': files
        }
        
        logger.info(f"Retornando {len(files)} arquivos")
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET, OPTIONS'
            },
            'body': json.dumps(data, indent=2)
        }
        
    except Exception as e:
        logger.error(f"Erro ao buscar dados: {str(e)}", exc_info=True)
        
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'success': False,
                'error': str(e),
                'message': 'Erro ao buscar dados'
            })
        }



