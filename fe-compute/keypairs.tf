###############################################################
# SSH key pair
# Created on the Mac with ssh-keygen and stored in AWS Secrets Manager
# (scripts/create-ssh-keys.sh). Terraform only reads it:
#   - public key  -> data source (not secret, fine in state)
#   - private key -> ephemeral resource (never written to plan or state)
###############################################################

data "aws_secretsmanager_secret_version" "fe_public_key" {
  secret_id = "${var.secret_prefix}/frontend/ssh-public-key"
}

ephemeral "aws_secretsmanager_secret_version" "fe_private_key" {
  secret_id = "${var.secret_prefix}/frontend/ssh-private-key"
}

locals {
  # Ephemeral value: allowed only in provisioner / connection blocks
  fe_private_key = ephemeral.aws_secretsmanager_secret_version.fe_private_key.secret_string
}

resource "aws_key_pair" "fe_keypair" {
  key_name   = "${var.frontend_prefix}-ssh-key"
  public_key = trimspace(data.aws_secretsmanager_secret_version.fe_public_key.secret_string)
}
