/* Using aws_vpc_security_group_egress_rule and aws_vpc_security_group_ingress_rule resources is the current best practice.
Avoid using the aws_security_group_rule resource and the ingress and egress arguments of the aws_security_group resource for configuring in-line rules,
as they struggle with managing multiple CIDR blocks, and tags and descriptions due to the historical lack of unique IDs. */

resource "aws_security_group" "fe_public_sg01" {
  name   = "${var.frontend_prefix}-public-security-group01"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8 # ICMP Type 8 = Echo Request (ping)
    to_port     = 0 # ICMP Code 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound ping (ICMP Echo Request)"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.frontend_prefix}-public-security-group01"
  }
}

#############################################################
resource "aws_security_group" "fe_private_sg01" {
  name   = "${var.frontend_prefix}-private-security-group01"
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.frontend_prefix}-private-security-group01"
  }
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg01_allow_ssh" {
  security_group_id            = aws_security_group.fe_private_sg01.id
  referenced_security_group_id = aws_security_group.fe_public_sg01.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg01_allow_icmp" {
  security_group_id            = aws_security_group.fe_private_sg01.id
  referenced_security_group_id = aws_security_group.fe_public_sg01.id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0
}

resource "aws_vpc_security_group_egress_rule" "fe_private_sg01_allow_all_traffic" {
  security_group_id = aws_security_group.fe_private_sg01.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all ports
}

#############################################################
resource "aws_security_group" "fe_private_sg02" {
  name   = "${var.frontend_prefix}-private-security-group02"
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.frontend_prefix}-private-security-group02"
  }
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg02_allow_ssh_from_fe_private_sg01" {
  security_group_id            = aws_security_group.fe_private_sg02.id
  referenced_security_group_id = aws_security_group.fe_private_sg01.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg02_allow_icmp_from_fe_private_sg01" {
  security_group_id            = aws_security_group.fe_private_sg02.id
  referenced_security_group_id = aws_security_group.fe_private_sg01.id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0
}

#############################################################
resource "aws_security_group" "fe_private_sg03" {
  name   = "${var.frontend_prefix}-private-security-group03"
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.frontend_prefix}-private-security-group03"
  }
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg03_allow_ssh_from_fe_private_sg01" {
  security_group_id            = aws_security_group.fe_private_sg03.id
  referenced_security_group_id = aws_security_group.fe_private_sg01.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg03_allow_icmp_from_fe_private_sg01" {
  security_group_id            = aws_security_group.fe_private_sg03.id
  referenced_security_group_id = aws_security_group.fe_private_sg01.id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0
}
