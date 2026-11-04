terraform {
  required_version = ">= 1.17.0" # ephemeral resources need >= 1.10

  cloud {
    organization = "Sandar-Cloud-Lab"

    workspaces {
      project = "VCS-OIDC"
      name    = "fe-network-ws"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# update version 
