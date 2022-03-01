data "aws_ami" "ubuntu" {
  owners = ["self"]

  most_recent = true

  filter {
    name   = "name"
    values = ["hashistack-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "consul" {
  name        = "consul-cts"
  description = "consul-cts"
  vpc_id      = data.terraform_remote_state.infra.outputs.aws_shared_svcs_vpc

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16", "10.2.0.0/16"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16", "10.2.0.0/16"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = ["10.1.0.0/16", "10.2.0.0/16"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "cts" {
    ami                         = data.aws_ami.ubuntu.id
    instance_type               = "t3.small"
    key_name                    = data.terraform_remote_state.infra.outputs.aws_ssh_key_name
    vpc_security_group_ids      = [aws_security_group.consul.id]
    subnet_id                   = data.terraform_remote_state.infra.outputs.aws_shared_svcs_public_subnets[0]
    associate_public_ip_address = true
    tags = {
      Name = "consul-cts"
    }
    user_data                   = data.template_file.init_cts.rendered
    iam_instance_profile        = data.terraform_remote_state.iam.outputs.aws_cts_iam_instance_profile_name

    provisioner "file" {
      source      = "security_input.tfvars"
      destination = "/home/ubuntu/security_input.tfvars"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host = self.public_ip
    }
  }
}

data "template_file" "init_cts" {
  template = file("${path.module}/scripts/cts.sh")
  vars = {
    env = data.terraform_remote_state.infra.outputs.env
  }
}
