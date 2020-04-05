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

resource "aws_security_group" "bastion-shared-svcs" {
  name        = "bastion"
  description = "bastion"
  vpc_id      = module.vpc-shared-svcs.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "bastion-shared-svcs" {
  instance_type               = "t3.small"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = "instruqt"
  vpc_security_group_ids      = ["${aws_security_group.bastion-shared-svcs.id}"]
  subnet_id                   = module.vpc-shared-svcs.public_subnets[0]
  associate_public_ip_address = true

  tags = {
    Name = "bastion"
  }
}
