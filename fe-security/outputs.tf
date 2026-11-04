output "public_sg_id" {
  value = aws_security_group.fe_public_sg01.id
}

output "private_sg_ids" {
  description = "[private-sg01, sg02, sg03]"
  value = [
    aws_security_group.fe_private_sg01.id,
    aws_security_group.fe_private_sg02.id,
    aws_security_group.fe_private_sg03.id,
  ]
}
