terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=3.56"
		}
	}
}

resource "aws_security_group_rule" "group" {
	for_each          = var.services
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  cidr_blocks       = ["${each.value.node_address}/32"]
  description       = "security group rule added by CTS"
  security_group_id = var.security_group_id
}


provider "aws" {
  #version = "~> 3.0"
  region  = "us-east-1"
  #profile = "AWSAugust03"
  #access_key = "AWS_ACCESS_KEY_ID"
  #secret_key = "AWS_SECRET_ACCESS_KEY"
  #token = "AWS_SESSION_TOKEN"
}

