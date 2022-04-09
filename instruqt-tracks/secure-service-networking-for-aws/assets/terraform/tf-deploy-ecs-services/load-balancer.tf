resource "aws_lb" "frontend" {
  name               = "frontend-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.frontend.id]
  subnets            = local.ecs_dev_public_subnets
}

#resource "aws_lb_target_group" "frontend" {
#  name                 = "frontend-app"
#  port                 = 3000
#  protocol             = "HTTP"
#  vpc_id               = local.ecs_dev_aws_vpc_id
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

resource "aws_lb_target_group" "hashicups" {

  for_each             = { for service in var.target_group_settings.elb.services : service.name => service }
  name                 = each.value.name
  port                 = each.value.port
  protocol             = each.value.protocol
  target_type          = each.value.target_group_type
  vpc_id               = local.ecs_dev_aws_vpc_id
  deregistration_delay = 10
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 30
    interval            = 60
    // Try function added due to public-api not listening on the default traffic ports but port 8080
    port                = try(each.value.health.port, "traffic-port")
  }
}

resource "aws_lb_listener" "hashicups" {
  for_each          = aws_lb_target_group.hashicups
  load_balancer_arn = aws_lb.frontend.arn
  port              = each.value.port
  protocol          = each.value.protocol
  default_action {
    type             = "forward"
    target_group_arn = each.value.arn
  }
} 