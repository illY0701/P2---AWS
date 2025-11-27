output "instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "IP público da instância"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "DNS público da instância"
  value       = aws_instance.web.public_dns
}

output "private_ip" {
  description = "IP privado da instância"
  value       = aws_instance.web.private_ip
}

output "security_group_id" {
  description = "ID do security group"
  value       = aws_security_group.ec2.id
}



