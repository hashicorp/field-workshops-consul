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

resource "aws_key_pair" "demo" {
  key_name   = "instruqt-${random_string.env.result}"
  public_key = var.ssh_public_key
}

module "aws-vpc-shared-svcs" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> v2.0"

  name = "terraform-vpc-shared-svcs"

  cidr = "10.1.0.0/16"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  private_subnets = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
  public_subnets  = ["10.1.3.0/24", "10.1.4.0/24", "10.1.5.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnet_tags = { "Tier" : "private" }
  public_subnet_tags  = { "Tier" : "public" }

}

module "aws-vpc-app" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> v2.0"

  name = "terraform-vpc-app"

  cidr = "10.2.0.0/16"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  private_subnets = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
  public_subnets  = ["10.2.3.0/24", "10.2.4.0/24", "10.2.5.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnet_tags = { "Tier" : "private" }
  public_subnet_tags  = { "Tier" : "public", "kubernetes.io/cluster/app" : "shared", "kubernetes.io/role/elb" : "1" }
  vpc_tags            = { "kubernetes.io/cluster/app" : "shared" }
}

resource "aws_vpc_peering_connection" "sharing-svcs" {
  vpc_id      = module.aws-vpc-shared-svcs.vpc_id
  peer_vpc_id = module.aws-vpc-app.vpc_id
  peer_region = "us-east-1"
  auto_accept = false

  tags = {
    Side = "Requester"
  }
}

resource "aws_vpc_peering_connection_accepter" "app" {
  vpc_peering_connection_id = aws_vpc_peering_connection.sharing-svcs.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

resource "aws_security_group" "bastion-shared-svcs" {
  name        = "bastion"
  description = "bastion"
  vpc_id      = module.aws-vpc-shared-svcs.vpc_id

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
  key_name                    = aws_key_pair.demo.key_name
  vpc_security_group_ids      = [aws_security_group.bastion-shared-svcs.id]
  subnet_id                   = module.aws-vpc-shared-svcs.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install redis -y
    EOF
  tags = {
    Name = "bastion"
  }
}
