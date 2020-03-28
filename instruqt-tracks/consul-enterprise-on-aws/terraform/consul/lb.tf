resource "aws_lb" "consul" {
  name               = "consul-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.consul_lb.id}"]
  subnets            = data.terraform_remote_state.vpc.outputs.shared_svcs_public_subnets
}

resource "aws_lb_listener" "ui" {
  load_balancer_arn = aws_lb.consul.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = module.consul.target_group
  }
}
