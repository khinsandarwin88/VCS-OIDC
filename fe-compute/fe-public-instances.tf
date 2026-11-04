# Amazon Linux 2023 (Amazon Linux 2 reached end of support on 2026-06-30)
data "aws_ami" "fe_public_instance_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
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

resource "aws_eip" "frontend_public_instance_eip" {
  domain = "vpc"

  tags = {
    Name        = "${var.frontend_prefix}-public-instance-eip-${var.region}"
    environment = var.frontend_environment
  }
}

resource "aws_eip_association" "fe_public_instance_eip_assoc" {
  instance_id   = aws_instance.frontend_public_instance01.id
  allocation_id = aws_eip.frontend_public_instance_eip.id
}

resource "aws_instance" "frontend_public_instance01" {
  ami                    = data.aws_ami.fe_public_instance_ami.id
  instance_type          = var.fe_instance_type
  key_name               = aws_key_pair.fe_keypair.key_name
  subnet_id              = local.public_subnet_ids[0]
  vpc_security_group_ids = [local.public_sg_id]

  tags = {
    Name        = "${var.frontend_prefix}-public-instance01"
    environment = var.frontend_environment
  }
}

resource "null_resource" "configure-fe-public-instance01" {
  depends_on = [aws_instance.frontend_public_instance01, aws_eip_association.fe_public_instance_eip_assoc]

  triggers = {
    # Re-run only when the instance or the deploy script changes
    instance_id = aws_instance.frontend_public_instance01.id
    script_hash = filemd5("${path.module}/files/deploy_app.sh")
  }

  provisioner "file" {
    source      = "${path.module}/files/"
    destination = "/home/ec2-user/"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = local.fe_private_key
      host        = aws_eip.frontend_public_instance_eip.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",

      # Install Apache httpd only if not present
      "if ! rpm -q httpd >/dev/null 2>&1; then sudo yum -y install httpd; fi",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd",

      "if [ -d /var/www/html ]; then sudo chown -R ec2-user:ec2-user /var/www/html; fi",
      "if ls *.sh 1> /dev/null 2>&1; then chmod +x *.sh; fi",

      # Run the deployment script if it exists
      "if [ -f ./deploy_app.sh ]; then PLACEHOLDER=${var.fe_placeholder} WIDTH=${var.width} HEIGHT=${var.height} PLACEHOLDER_ID=${var.placeholder_id} PREFIX=${var.frontend_prefix} ./deploy_app.sh; fi",

      # cowsay is not in the AL2023 repos, so never fail the run on it
      "command -v cowsay >/dev/null 2>&1 || sudo yum -y install cowsay || true",
      "cowsay Hellooooooooooo! || echo Hellooooooooooo!",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = local.fe_private_key
      host        = aws_eip.frontend_public_instance_eip.public_ip
    }
  }
}
