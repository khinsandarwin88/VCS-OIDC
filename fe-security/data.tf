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
  vpc_id = data.terraform_remote_state.fe_network.outputs.vpc_id
}
