variable "region" {
  description = "The region where the resources are created."
  default     = "eu-west-1"
}

variable "backend_prefix" {
  description = "The prefix for the backend resources."
  default     = "backend"
}

variable "backend_environment" {
  description = "The environment for the backend resources."
  default     = "dev"
}

variable "be_instance_type" {
  description = "Specifies the AWS instance type."
  default     = "t3.micro"
}

variable "tfc_organization" {
  description = "HCP Terraform organization (used to read other workspaces' outputs)."
  default     = "Sandar-Cloud-Lab"
}

variable "be_network_workspace" {
  default = "be-network-ws"
}

variable "be_security_workspace" {
  default = "be-security-ws"
}

#############################################################
# App Variables
#############################################################

variable "be_placeholder" {
  default     = "placebear.com"
  description = "Image-as-a-service URL, e.g. placedog.net, placebear.com, loremflickr.com"
}

variable "placeholder_id" {
  default     = "2"
  description = "Image id passed to the placeholder service."
}

variable "width" {
  default     = "600"
  description = "Image width in pixels."
}

variable "height" {
  default     = "400"
  description = "Image height in pixels."
}

#############################################################
# Secrets Manager
#############################################################

variable "secret_prefix" {
  description = "Secrets Manager name prefix used by scripts/create-ssh-keys.sh"
  default     = "vcs-workflow"
}
