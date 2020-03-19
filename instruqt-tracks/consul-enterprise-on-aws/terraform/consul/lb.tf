resource "aws_security_group" "consul_lb" {
  vpc_id = var.vpc_id

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

resource "aws_lb_target_group" "consul" {
  port     = 8500
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  deregistration_delay = "15"

  health_check {
    path     = "/v1/status/leader"
    port     = "8500"
    protocol = "HTTP"
  }
}

resource "aws_lb" "consul" {
  name               = "consul-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.consul_lb.id}"]
  subnets            = split(",", var.subnets)
}

resource "aws_lb_listener" "ui" {
  load_balancer_arn = "${aws_lb.consul.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.consul.arn}"
  }
}
