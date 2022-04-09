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

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "deployer-one"
  public_key = tls_private_key.this.public_key_openssh
}

data "template_file" "aws_mgw_init" {
  template = file("${path.module}/scripts/ecs_mesh_gw.sh")
  vars = {
    agent_config = file("/root/config/hcp_client_config.json")
    token = local.hcp_acl_token_secret_id
    ca = file("/root/config/hcp_ca.pem")
    partition = "ecs-dev"
  }
}

resource "aws_instance" "mesh_gateway" {
  instance_type               = "t3.small"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = module.key_pair.key_pair_key_name
  subnet_id                   = local.ecs_dev_public_subnets[0]
  associate_public_ip_address = true
  user_data                   = data.template_file.aws_mgw_init.rendered
  tags = {
    Name = "consul-mgw"
  }
}
