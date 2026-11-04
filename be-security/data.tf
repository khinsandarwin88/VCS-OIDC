data "terraform_remote_state" "be_network" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = var.be_network_workspace
    }
  }
}

locals {
  vpc_id = data.terraform_remote_state.be_network.outputs.vpc_id
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
