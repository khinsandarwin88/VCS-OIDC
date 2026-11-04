terraform {
  required_version = ">= 1.12" # ephemeral resources need >= 1.10

  cloud {
    organization = "Sandar-Cloud-Lab"

    workspaces {
      project = "VCS-OIDC"
      name    = "be-compute-ws"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.0"
    }
  }
}
