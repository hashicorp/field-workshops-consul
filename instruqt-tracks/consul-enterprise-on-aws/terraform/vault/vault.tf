data "aws_ami" "ubuntu" {
  owners = ["099720109477"]

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "vault" {
  name        = "bastion"
  description = "bastion"
  vpc_id      = data.terraform_remote_state.vpc.outputs.shared_svcs_vpc

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8200
    to_port     = 8200
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

resource "aws_instance" "vault" {
  instance_type               = "t2.small"
  ami                         = "${data.aws_ami.ubuntu.id}"
  key_name                    = "instruqt"
  vpc_security_group_ids      = ["${data.terraform_remote_state.vpc.outputs.shared_svcs_vpc}"]
  subnet_id                   = "${data.terraform_remote_state.vpc.outputs.shared_svcs_private_subnets[0]}"
  associate_public_ip_address = false
  user_data                   = file("${path.module}/scripts/vault.sh")

  tags = {
    Name = "vault"
  }
}
