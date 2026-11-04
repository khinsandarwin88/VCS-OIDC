output "vpc_id" {
  value = aws_vpc.backend_vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.backend_vpc.cidr_block
}

output "public_subnet_ids" {
  description = "[public-subnet01, 02, 03]"
  value = [
    aws_subnet.backend_public_subnet01.id,
    aws_subnet.backend_public_subnet02.id,
    aws_subnet.backend_public_subnet03.id,
  ]
}

output "private_subnet_ids" {
  description = "[private-subnet01, 02, 03]"
  value = [
    aws_subnet.backend_private_subnet01.id,
    aws_subnet.backend_private_subnet02.id,
    aws_subnet.backend_private_subnet03.id,
  ]
}

output "private_subnet_cidrs" {
  value = var.backend_private_subnet_cidr
}

output "private_route_table_ids" {
  description = "[private-rtb01, 02, 03]"
  value = [
    aws_route_table.backend_private_rtb01.id,
    aws_route_table.backend_private_rtb02.id,
    aws_route_table.backend_private_rtb03.id,
  ]
}

output "peering_connection_id" {
  value = aws_vpc_peering_connection.fevpc_peering_bevpc.id
}
