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

resource "aws_security_group" "nomad" {
  name        = "nomad"
  description = "nomad"
  vpc_id      = data.terraform_remote_state.infra.outputs.aws_shared_svcs_vpc

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4646
    to_port     = 4646
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4647
    to_port     = 4647
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4648
    to_port     = 4648
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 20000
    to_port     = 32000
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

resource "aws_instance" "nomad" {
  instance_type               = "t3.small"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = data.terraform_remote_state.infra.outputs.aws_ssh_key_name
  vpc_security_group_ids      = [aws_security_group.nomad.id]
  subnet_id                   = data.terraform_remote_state.infra.outputs.aws_shared_svcs_public_subnets[0]
  associate_public_ip_address = true
  user_data                   = data.template_file.init.rendered
  iam_instance_profile        = data.terraform_remote_state.iam.outputs.aws_nomad_iam_instance_profile_name
  tags = {
    Name = "nomad"
    Env  = "nomad-${data.terraform_remote_state.infra.outputs.env}"
  }
}

data "template_file" "init" {
  template = file("${path.module}/scripts/aws_nomad_server.sh")
  vars = {
    env = data.terraform_remote_state.infra.outputs.env
  }
}

resource "aws_instance" "nomad-client" {
  count = 1

  instance_type               = "t3.small"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = data.terraform_remote_state.infra.outputs.aws_ssh_key_name
  vpc_security_group_ids      = [aws_security_group.nomad.id]
  subnet_id                   = data.terraform_remote_state.infra.outputs.aws_shared_svcs_public_subnets[0]
  associate_public_ip_address = true
  user_data                   = data.template_file.nomad-client.rendered
  iam_instance_profile        = data.terraform_remote_state.iam.outputs.aws_consul_iam_instance_profile_name
  tags = {
    Name = "nomad-client"
    Env  = "nomad-${data.terraform_remote_state.infra.outputs.env}"
  }
}

data "template_file" "nomad-client" {
  template = file("${path.module}/scripts/aws_nomad_client.sh")
  vars = {
    env = data.terraform_remote_state.infra.outputs.env
  }
}
