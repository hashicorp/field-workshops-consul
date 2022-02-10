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


resource "aws_instance" "mesh_gateway" {
  instance_type               = "t3.small"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = module.key_pair.key_pair_key_name
#  key_name                    = data.terraform_remote_state.infra.outputs.aws_ssh_key_name
#  vpc_security_group_ids      = [aws_security_group.consul.id]
  subnet_id                   = data.terraform_remote_state.hcp.outputs.ecs_public_subnets[0]
  associate_public_ip_address = true
  user_data                   = data.template_file.aws_mgw_init.rendered
#  user_data                   = file("${path.module}/scripts/ecs_mesh_gw.sh")
#  iam_instance_profile        = data.terraform_remote_state.iam.outputs.aws_consul_iam_instance_profile_name
  tags = {
    Name = "consul-mgw"
  }
}

data "template_file" "aws_mgw_init" {
  template = file("${path.module}/scripts/ecs_mesh_gw.sh")
  vars = {
    agent_config = file("/root/config/hcp_client_config.json")
    token = data.terraform_remote_state.hcp.outputs.hcp_acl_token.secret_id
    ca = file("/root/config/hcp_ca.pem")
  }
}