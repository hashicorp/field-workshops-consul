resource "aws_lb" "consul" {
  name               = "consul-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = data.terraform_remote_state.vpc.outputs.shared_svcs_public_subnets
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.consul.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = module.consul.http_target_group
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.consul.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = module.consul.https_target_group
  }
}
