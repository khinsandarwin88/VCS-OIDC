#############################################################
# Cross-VPC rules (frontend <-> backend over VPC peering)
# Lives here (not in fe-security-ws) to avoid a circular dependency:
# fe SGs are created first, then backend SGs + both sides' cross rules.
#   fe private-sg02 <-> be private-sg02
#   fe private-sg03 <-> be private-sg03
#############################################################

locals {
  fe_private_sg_ids = data.terraform_remote_state.fe_security.outputs.private_sg_ids
  be_private_sg_ids = [
    aws_security_group.be_private_sg01.id,
    aws_security_group.be_private_sg02.id,
    aws_security_group.be_private_sg03.id,
  ]

  # idx 1 = sg02, idx 2 = sg03
  peer_rules = {
    "sg02-ssh"  = { idx = 1, protocol = "tcp", from = 22, to = 22 }
    "sg02-icmp" = { idx = 1, protocol = "icmp", from = 8, to = 0 }
    "sg03-ssh"  = { idx = 2, protocol = "tcp", from = 22, to = 22 }
    "sg03-icmp" = { idx = 2, protocol = "icmp", from = 8, to = 0 }
  }
}

# ---------- backend side ----------
resource "aws_vpc_security_group_ingress_rule" "be_from_fe" {
  for_each = local.peer_rules

  security_group_id            = local.be_private_sg_ids[each.value.idx]
  referenced_security_group_id = local.fe_private_sg_ids[each.value.idx]
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.from
  to_port                      = each.value.to
}

resource "aws_vpc_security_group_egress_rule" "be_to_fe" {
  for_each = local.peer_rules

  security_group_id            = local.be_private_sg_ids[each.value.idx]
  referenced_security_group_id = local.fe_private_sg_ids[each.value.idx]
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.from
  to_port                      = each.value.to
}

# ---------- frontend side ----------
resource "aws_vpc_security_group_ingress_rule" "fe_from_be" {
  for_each = local.peer_rules

  security_group_id            = local.fe_private_sg_ids[each.value.idx]
  referenced_security_group_id = local.be_private_sg_ids[each.value.idx]
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.from
  to_port                      = each.value.to
}

resource "aws_vpc_security_group_egress_rule" "fe_to_be" {
  for_each = local.peer_rules

  security_group_id            = local.fe_private_sg_ids[each.value.idx]
  referenced_security_group_id = local.be_private_sg_ids[each.value.idx]
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.from
  to_port                      = each.value.to
}
