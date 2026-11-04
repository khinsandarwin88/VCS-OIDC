# Read frontend VPC outputs from fe-network-ws
data "terraform_remote_state" "fe_network" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = var.fe_network_workspace
    }
  }
}

locals {
  fe_vpc_id                  = data.terraform_remote_state.fe_network.outputs.vpc_id
  fe_private_route_table_ids = data.terraform_remote_state.fe_network.outputs.private_route_table_ids
  fe_private_subnet_cidrs    = data.terraform_remote_state.fe_network.outputs.private_subnet_cidrs
}
