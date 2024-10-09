resource "aws_lb" "csye6225-lb" {

  name = "csye6225-lb"

  internal = false

  load_balancer_type = "application"
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]
  security_groups    = [aws_security_group.load_balancer.id]

  tags = {

    Application = "WebApp-lb"

  }
  depends_on = [
    aws_security_group.load_balancer,
    aws_subnet.public_subnet
  ]

}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.csye6225-lb.arn
  port              = var.lb_listener_port
  protocol          = var.lb_listener_protocol
  certificate_arn   = var.cert

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.alb_tg.arn

  }

}


resource "aws_lb_target_group" "alb_tg" {

  name = "csye6225-lb-alb-tg"

  target_type = "instance"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.example_vpc.id

  #deregistration_delay =10
  health_check {
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    timeout             = var.timeout
    interval            = var.interval
    path                = var.path
    port                = "8080"
    matcher             = "200"

  }

}

