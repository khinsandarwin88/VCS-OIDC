data "terraform_remote_state" "fe_network" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = var.fe_network_workspace
    }
  }
}

data "terraform_remote_state" "fe_security" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = var.fe_security_workspace
    }
  }
}

locals {
  public_subnet_ids  = data.terraform_remote_state.fe_network.outputs.public_subnet_ids
  private_subnet_ids = data.terraform_remote_state.fe_network.outputs.private_subnet_ids
  public_sg_id       = data.terraform_remote_state.fe_security.outputs.public_sg_id
  private_sg_ids     = data.terraform_remote_state.fe_security.outputs.private_sg_ids
}
