resource "aws_lb" "frontend" {
  name               = "${var.name}-frontend-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.frontend.id]
  subnets            = local.ecs_dev_public_subnets
}

resource "aws_lb_target_group" "frontend" {
  name                 = "${var.name}-frontend-app"
  port                 = 9090
  protocol             = "HTTP"
  vpc_id               = local.ecs_dev_aws_vpc_id
  target_type          = "ip"
  deregistration_delay = 10
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 30
    interval            = 60
  }
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = "9090"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}