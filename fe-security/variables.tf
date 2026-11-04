variable "region" {
  description = "The region where the resources are created."
  default     = "eu-west-1"
}

variable "frontend_prefix" {
  description = "The prefix for the frontend resources."
  default     = "frontend"
}

variable "tfc_organization" {
  description = "HCP Terraform organization (used to read other workspaces' outputs)."
  default     = "Sandar-Cloud-Lab"
}

variable "fe_network_workspace" {
  default = "fe-network-ws"
}
