output "frontend_public_instance_public_ip" {
  description = "Public (Elastic) IP of the frontend public instance"
  value       = aws_eip.frontend_public_instance_eip.public_ip
}

output "frontend_public_instance_public_dns" {
  description = "Public DNS of the frontend public instance"
  value       = aws_eip.frontend_public_instance_eip.public_dns
}

output "frontend_private_instance01_private_ip" {
  value = aws_instance.frontend_private_instance01.private_ip
}

output "frontend_private_instance02_private_ip" {
  value = aws_instance.frontend_private_instance02.private_ip
}

output "frontend_private_instance03_private_ip" {
  value = aws_instance.frontend_private_instance03.private_ip
}
