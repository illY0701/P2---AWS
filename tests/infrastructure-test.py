#!/usr/bin/env python3
"""
Infrastructure Test Suite
Testes automatizados para validar a infraestrutura AWS
"""

import json
import sys
import subprocess
import requests
from typing import Dict, List, Tuple
from datetime import datetime

class Colors:
    """Cores para output no terminal"""
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

class InfrastructureTest:
    """Classe para testes de infraestrutura"""
    
    def __init__(self):
        self.results: List[Tuple[str, bool, str]] = []
        self.outputs = self.load_terraform_outputs()
        
    def load_terraform_outputs(self) -> Dict:
        """Carrega outputs do Terraform"""
        try:
            result = subprocess.run(
                ['terraform', 'output', '-json'],
                cwd='terraform',
                capture_output=True,
                text=True,
                check=True
            )
            outputs = json.loads(result.stdout)
            return {k: v['value'] for k, v in outputs.items()}
        except Exception as e:
            print(f"{Colors.RED}Erro ao carregar outputs: {e}{Colors.ENDC}")
            return {}
    
    def log_test(self, test_name: str, passed: bool, message: str = ""):
        """Registra resultado de um teste"""
        self.results.append((test_name, passed, message))
        
        status = f"{Colors.GREEN}✓ PASS{Colors.ENDC}" if passed else f"{Colors.RED}✗ FAIL{Colors.ENDC}"
        print(f"{status} - {test_name}")
        if message:
            print(f"      {message}")
    
    def test_ec2_connectivity(self):
        """Testa conectividade com EC2"""
        test_name = "EC2 Web Server"
        try:
            ec2_ip = self.outputs.get('ec2_public_ip')
            if not ec2_ip:
                self.log_test(test_name, False, "IP público não encontrado")
                return
            
            url = f"http://{ec2_ip}"
            response = requests.get(url, timeout=10)
            
            if response.status_code == 200:
                self.log_test(test_name, True, f"Respondendo em {url}")
            else:
                self.log_test(test_name, False, f"Status code: {response.status_code}")
        except Exception as e:
            self.log_test(test_name, False, str(e))
    
    def test_api_gateway_status(self):
        """Testa endpoint /status da API Gateway"""
        test_name = "API Gateway - /status"
        try:
            api_url = self.outputs.get('api_gateway_url')
            if not api_url:
                self.log_test(test_name, False, "URL da API não encontrada")
                return
            
            url = f"{api_url}/status"
            response = requests.get(url, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                if data.get('status') == 'online':
                    self.log_test(test_name, True, "API online e funcionando")
                else:
                    self.log_test(test_name, False, f"Status: {data.get('status')}")
            else:
                self.log_test(test_name, False, f"Status code: {response.status_code}")
        except Exception as e:
            self.log_test(test_name, False, str(e))
    
    def test_api_gateway_process(self):
        """Testa endpoint /process da API Gateway"""
        test_name = "API Gateway - /process"
        try:
            api_url = self.outputs.get('api_gateway_url')
            if not api_url:
                self.log_test(test_name, False, "URL da API não encontrada")
                return
            
            url = f"{api_url}/process"
            payload = {
                "message": "Test from automated test suite",
                "timestamp": datetime.utcnow().isoformat()
            }
            
            response = requests.post(url, json=payload, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    self.log_test(test_name, True, "Processamento bem-sucedido")
                else:
                    self.log_test(test_name, False, "Processamento falhou")
            else:
                self.log_test(test_name, False, f"Status code: {response.status_code}")
        except Exception as e:
            self.log_test(test_name, False, str(e))
    
    def test_api_gateway_data(self):
        """Testa endpoint /data da API Gateway"""
        test_name = "API Gateway - /data"
        try:
            api_url = self.outputs.get('api_gateway_url')
            if not api_url:
                self.log_test(test_name, False, "URL da API não encontrada")
                return
            
            url = f"{api_url}/data"
            response = requests.get(url, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                if 'stats' in data:
                    self.log_test(test_name, True, f"Retornou {data['stats']['total_files']} arquivos")
                else:
                    self.log_test(test_name, False, "Resposta inválida")
            else:
                self.log_test(test_name, False, f"Status code: {response.status_code}")
        except Exception as e:
            self.log_test(test_name, False, str(e))
    
    def test_s3_bucket(self):
        """Testa bucket S3"""
        test_name = "S3 Bucket Access"
        try:
            bucket_name = self.outputs.get('s3_assets_bucket_name')
            if not bucket_name:
                self.log_test(test_name, False, "Nome do bucket não encontrado")
                return
            
            result = subprocess.run(
                ['aws', 's3', 'ls', f's3://{bucket_name}'],
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                self.log_test(test_name, True, f"Bucket {bucket_name} acessível")
            else:
                self.log_test(test_name, False, "Falha ao acessar bucket")
        except Exception as e:
            self.log_test(test_name, False, str(e))
    
    def test_rds_status(self):
        """Testa status do RDS"""
        test_name = "RDS Instance"
        try:
            result = subprocess.run(
                ['aws', 'rds', 'describe-db-instances',
                 '--query', 'DBInstances[0].DBInstanceStatus',
                 '--output', 'text'],
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                status = result.stdout.strip()
                if status == 'available':
                    self.log_test(test_name, True, "RDS disponível")
                else:
                    self.log_test(test_name, False, f"Status: {status}")
            else:
                self.log_test(test_name, False, "Falha ao consultar RDS")
        except Exception as e:
            self.log_test(test_name, False, str(e))
    
    def test_ecs_cluster(self):
        """Testa cluster ECS"""
        test_name = "ECS Cluster"
        try:
            cluster_name = self.outputs.get('ecs_cluster_name')
            if not cluster_name:
                self.log_test(test_name, False, "Nome do cluster não encontrado")
                return
            
            result = subprocess.run(
                ['aws', 'ecs', 'describe-clusters',
                 '--clusters', cluster_name,
                 '--query', 'clusters[0].runningTasksCount',
                 '--output', 'text'],
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                task_count = result.stdout.strip()
                if int(task_count) > 0:
                    self.log_test(test_name, True, f"{task_count} task(s) em execução")
                else:
                    self.log_test(test_name, False, "Nenhuma task em execução")
            else:
                self.log_test(test_name, False, "Falha ao consultar ECS")
        except Exception as e:
            self.log_test(test_name, False, str(e))
    
    def test_lambda_functions(self):
        """Testa funções Lambda"""
        test_name = "Lambda Functions"
        try:
            result = subprocess.run(
                ['aws', 'lambda', 'list-functions',
                 '--query', 'length(Functions)',
                 '--output', 'text'],
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                function_count = int(result.stdout.strip())
                if function_count >= 3:
                    self.log_test(test_name, True, f"{function_count} funções criadas")
                else:
                    self.log_test(test_name, False, f"Apenas {function_count} funções")
            else:
                self.log_test(test_name, False, "Falha ao listar funções")
        except Exception as e:
            self.log_test(test_name, False, str(e))
    
    def run_all_tests(self):
        """Executa todos os testes"""
        print(f"\n{Colors.HEADER}{Colors.BOLD}{'='*60}{Colors.ENDC}")
        print(f"{Colors.HEADER}{Colors.BOLD}  Teste de Infraestrutura AWS{Colors.ENDC}")
        print(f"{Colors.HEADER}{Colors.BOLD}{'='*60}{Colors.ENDC}\n")
        
        tests = [
            self.test_ec2_connectivity,
            self.test_api_gateway_status,
            self.test_api_gateway_process,
            self.test_api_gateway_data,
            self.test_s3_bucket,
            self.test_rds_status,
            self.test_ecs_cluster,
            self.test_lambda_functions
        ]
        
        for test in tests:
            test()
        
        # Resumo
        total = len(self.results)
        passed = sum(1 for _, p, _ in self.results if p)
        failed = total - passed
        
        print(f"\n{Colors.BOLD}{'='*60}{Colors.ENDC}")
        print(f"{Colors.BOLD}Resumo dos Testes:{Colors.ENDC}")
        print(f"  Total:   {total}")
        print(f"  {Colors.GREEN}Passou:  {passed}{Colors.ENDC}")
        print(f"  {Colors.RED}Falhou:  {failed}{Colors.ENDC}")
        print(f"{Colors.BOLD}{'='*60}{Colors.ENDC}\n")
        
        # Retornar código de saída
        return 0 if failed == 0 else 1

if __name__ == '__main__':
    tester = InfrastructureTest()
    sys.exit(tester.run_all_tests())



