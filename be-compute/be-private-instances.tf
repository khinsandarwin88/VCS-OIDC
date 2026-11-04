data "aws_ami" "be_private_instance_ami" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "backend_private_instance01" {
  ami                    = data.aws_ami.be_private_instance_ami.id
  instance_type          = var.be_instance_type
  key_name               = aws_key_pair.be_keypair.key_name
  subnet_id              = local.private_subnet_ids[0]
  vpc_security_group_ids = [local.private_sg_ids[0]]

  tags = {
    Name        = "${var.backend_prefix}-private-instance01"
    environment = var.backend_environment
  }
}

#####################################################
# Configure private-instance01 through the bastion (public-instance01)
resource "null_resource" "configure-be-private-instance01" {
  depends_on = [aws_instance.backend_public_instance01, aws_eip_association.be_public_instance_eip_assoc]

  triggers = {
    # Re-run only when the instance or the deploy script changes
    instance_id = aws_instance.backend_private_instance01.id
    script_hash = filemd5("${path.module}/files/deploy_app.sh")
  }

  provisioner "file" {
    source      = "${path.module}/files/"
    destination = "/home/ubuntu/"

    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = aws_instance.backend_private_instance01.private_ip
      private_key         = local.be_private_key
      bastion_host        = aws_eip.backend_public_instance_eip.public_ip
      bastion_user        = "ec2-user"
      bastion_private_key = local.be_private_key
    }
  }

  /* Remote-Exec Is Not Idempotent
    * Provisioners do not keep state: each apply re-runs every command.
    * Commands below check first (if ... then ...) so re-runs are safe.
    * For Day-N config management use Ansible/Chef/Puppet instead.
  */
  provisioner "remote-exec" {
    inline = [
      "sudo apt -y update",
      "if ! command -v cowsay >/dev/null 2>&1; then sudo apt -y install cowsay; fi",
      "/usr/games/cowsay Hellooooooooooo!",
      "if ! command -v unzip >/dev/null 2>&1; then sudo apt -y install unzip; fi",
      <<-EOT
      if ! aws --version 2>/dev/null | grep 'aws-cli/2.'; then
        sudo curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip;
        sudo unzip -o awscliv2.zip;
        sudo ./aws/install --update;
        sudo rm -rf awscliv2.zip aws;
      fi
      EOT
      ,
      "sudo aws --version",
    ]

    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = aws_instance.backend_private_instance01.private_ip
      private_key         = local.be_private_key
      bastion_host        = aws_eip.backend_public_instance_eip.public_ip
      bastion_user        = "ec2-user"
      bastion_private_key = local.be_private_key
    }
  }
}

#####################################################
resource "aws_instance" "backend_private_instance02" {
  ami                    = data.aws_ami.be_private_instance_ami.id
  instance_type          = var.be_instance_type
  key_name               = aws_key_pair.be_keypair.key_name
  subnet_id              = local.private_subnet_ids[1]
  vpc_security_group_ids = [local.private_sg_ids[1]]

  tags = {
    Name        = "${var.backend_prefix}-private-instance02"
    environment = var.backend_environment
  }
}

resource "aws_instance" "backend_private_instance03" {
  ami                    = data.aws_ami.be_private_instance_ami.id
  instance_type          = var.be_instance_type
  key_name               = aws_key_pair.be_keypair.key_name
  subnet_id              = local.private_subnet_ids[2]
  vpc_security_group_ids = [local.private_sg_ids[2]]

  tags = {
    Name        = "${var.backend_prefix}-private-instance03"
    environment = var.backend_environment
  }
}
