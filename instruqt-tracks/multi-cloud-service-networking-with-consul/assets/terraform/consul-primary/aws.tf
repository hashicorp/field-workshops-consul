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

resource "aws_security_group" "consul" {
  name        = "consul"
  description = "consul"
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

resource "aws_instance" "consul" {
  instance_type               = "t3.small"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = data.terraform_remote_state.infra.outputs.aws_ssh_key_name
  vpc_security_group_ids      = [aws_security_group.consul.id]
  subnet_id                   = data.terraform_remote_state.infra.outputs.aws_shared_svcs_public_subnets[0]
  associate_public_ip_address = true
  user_data                   = data.template_file.init.rendered
  iam_instance_profile        = data.terraform_remote_state.iam.outputs.aws_consul_iam_instance_profile_name
  tags = {
    Name = "consul"
    Env  = "consul-${data.terraform_remote_state.infra.outputs.env}"
  }
}

data "template_file" "init" {
  template = file("${path.module}/scripts/aws_consul_server.sh")
  vars = {
    ca_cert = tls_self_signed_cert.shared_ca.cert_pem
    cert    = tls_locally_signed_cert.aws_consul_server.cert_pem,
    key     = tls_private_key.aws_consul_server.private_key_pem
  }
}

resource "tls_private_key" "aws_consul_server" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "aws_consul_server" {
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.aws_consul_server.private_key_pem

  subject {
    common_name = "consul-server-0.server.aws-us-east-1.consul"
  }

  dns_names    = ["consul-server-0.server.aws-us-east-1.consul", "server.aws-us-east-1.consul", "localhost"]
  ip_addresses = ["127.0.0.1"]
}

resource "tls_locally_signed_cert" "aws_consul_server" {
  cert_request_pem   = tls_cert_request.aws_consul_server.cert_request_pem
  ca_key_algorithm   = tls_private_key.shared_ca.algorithm
  ca_private_key_pem = tls_private_key.shared_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.shared_ca.cert_pem

  validity_period_hours = 8600

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth",
    "server_auth"
  ]
}

resource "aws_instance" "mesh_gateway" {
  instance_type               = "t3.small"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = data.terraform_remote_state.infra.outputs.aws_ssh_key_name
  vpc_security_group_ids      = [aws_security_group.consul.id]
  subnet_id                   = data.terraform_remote_state.infra.outputs.aws_shared_svcs_public_subnets[0]
  associate_public_ip_address = true
  user_data                   = data.template_file.aws_mgw_init.rendered
  iam_instance_profile        = data.terraform_remote_state.iam.outputs.aws_consul_iam_instance_profile_name
  tags = {
    Name = "consul-mgw"
  }
}

data "template_file" "aws_mgw_init" {
  template = file("${path.module}/scripts/aws_mesh_gateway.sh")
  vars = {
    env     = data.terraform_remote_state.infra.outputs.env
    ca_cert = tls_self_signed_cert.shared_ca.cert_pem
  }
}
