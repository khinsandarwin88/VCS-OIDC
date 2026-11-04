output "vpc_id" {
  value = aws_vpc.frontend_vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.frontend_vpc.cidr_block
}

output "public_subnet_ids" {
  description = "[public-subnet01, 02, 03]"
  value = [
    aws_subnet.frontend_public_subnet01.id,
    aws_subnet.frontend_public_subnet02.id,
    aws_subnet.frontend_public_subnet03.id,
  ]
}

output "private_subnet_ids" {
  description = "[private-subnet01, 02, 03]"
  value = [
    aws_subnet.frontend_private_subnet01.id,
    aws_subnet.frontend_private_subnet02.id,
    aws_subnet.frontend_private_subnet03.id,
  ]
}

output "private_subnet_cidrs" {
  value = var.frontend_private_subnet_cidr
}

output "private_route_table_ids" {
  description = "[private-rtb01, 02, 03]"
  value = [
    aws_route_table.frontend_private_rtb01.id,
    aws_route_table.frontend_private_rtb02.id,
    aws_route_table.frontend_private_rtb03.id,
  ]
}
