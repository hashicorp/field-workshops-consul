# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "aws_security_group" "vault_lb" {
  vpc_id = data.terraform_remote_state.vpc.outputs.shared_svcs_vpc

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_lb_target_group" "vault" {
  port        = 8200
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.shared_svcs_vpc
  target_type = "instance"

  health_check {
    path     = "/v1/sys/health"
    port     = "8200"
    protocol = "HTTP"
  }
}

resource "aws_lb" "vault" {
  name               = "vault-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.vault_lb.id}"]
  subnets            = data.terraform_remote_state.vpc.outputs.shared_svcs_public_subnets
}

resource "aws_lb_listener" "vault" {
  load_balancer_arn = "${aws_lb.vault.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.vault.arn}"
  }
}


resource "aws_lb_target_group_attachment" "vault" {
  target_group_arn = aws_lb_target_group.vault.arn
  target_id        = aws_instance.vault.id
  port             = 8200
}
