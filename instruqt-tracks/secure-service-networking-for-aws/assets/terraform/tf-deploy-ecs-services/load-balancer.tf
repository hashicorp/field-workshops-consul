#resource "aws_lb" "example_client_app" {
#  name               = "${var.name}-example-client-app"
#  internal           = false
#  load_balancer_type = "application"
#  security_groups    = [aws_security_group.example_client_app_alb.id]
#  subnets            = var.public_subnets_ids
#}
#
#resource "aws_lb_target_group" "example_client_app" {
#  name                 = "${var.name}-example-client-app"
#  port                 = 9090
#  protocol             = "HTTP"
#  vpc_id               = data.terraform_remote_state.hcp.outputs.aws_vpc_ecs_id
#  target_type          = "ip"
#  deregistration_delay = 10
#  health_check {
#    path                = "/"
#    healthy_threshold   = 2
#    unhealthy_threshold = 10
#    timeout             = 30
#    interval            = 60
#  }
#}
#
#resource "aws_lb_listener" "example_client_app" {
#  load_balancer_arn = aws_lb.example_client_app.arn
#  port              = "9090"
#  protocol          = "HTTP"
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.example_client_app.arn
#  }
#}