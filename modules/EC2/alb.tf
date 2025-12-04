resource "aws_lb" "alb" {
  name               = var.alb_name
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = var.alb_security_groups
  subnets            = var.subnets
  enable_deletion_protection = var.enable_deletion_protection

}

resource "aws_lb_target_group" "tg" {
  name        = var.tg_name
  port        = var.tg_port
  protocol    = var.tg_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type
  deregistration_delay = var.deregistration_delay

  health_check {
    path                = var.health_check.path
    protocol            = var.health_check.protocol
    matcher             = var.health_check.matcher
    interval            = var.health_check.interval
    timeout             = var.health_check.timeout
    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
  }

}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type = var.default_action_type
    target_group_arn = (
      var.default_target_group_arn != "" ?
      var.default_target_group_arn :
      aws_lb_target_group.tg.arn
    )
  }
}

resource "aws_lb_target_group_attachment" "web_attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web.id   
  port             = var.listener_port
}