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

resource "aws_security_group" "vault" {
  name        = "vault"
  description = "vault"
  vpc_id      = data.terraform_remote_state.infra.outputs.aws_shared_svcs_vpc

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

  ingress {
    from_port   = 8201
    to_port     = 8201
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16", "10.2.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vault" {
  instance_type               = "t3.large"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = data.terraform_remote_state.infra.outputs.aws_ssh_key_name
  vpc_security_group_ids      = [aws_security_group.vault.id]
  subnet_id                   = data.terraform_remote_state.infra.outputs.aws_shared_svcs_public_subnets[0]
  associate_public_ip_address = true
  user_data                   = data.template_file.vault.rendered
  iam_instance_profile        = aws_iam_instance_profile.vault.name

  tags = {
    Name = "vault"
  }
}

data "template_file" "vault" {
  template = file("${path.module}/scripts/aws_vault.sh")
  vars = {
    env     = data.terraform_remote_state.infra.outputs.env
    kms_key = aws_kms_key.vault.key_id
  }
}

resource "aws_kms_key" "vault" {
  description             = "Vault ${data.terraform_remote_state.infra.outputs.env}"
  deletion_window_in_days = 10
}

resource "aws_iam_instance_profile" "vault" {
  name = "vault-${data.terraform_remote_state.infra.outputs.env}"
  role = aws_iam_role.vault.name
}

resource "aws_iam_role" "vault" {
  name = "vault-${data.terraform_remote_state.infra.outputs.env}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "vault" {
  name = "vault-${data.terraform_remote_state.infra.outputs.env}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:DescribeInstances",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "iam:GetInstanceProfile",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "iam:GetRole",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey"
      ],
      "Resource": [
        "arn:aws:kms:us-east-1:*:key/${aws_kms_key.vault.key_id}"
      ]
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "vault" {
  role       = aws_iam_role.vault.name
  policy_arn = aws_iam_policy.vault.arn
}
