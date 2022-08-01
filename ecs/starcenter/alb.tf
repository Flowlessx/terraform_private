### APP 
resource "aws_alb" "starcenter" {
  name            = "starcenter"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}


resource "aws_alb_target_group" "starcenter" {
  name        = "starcenter"
  port        = var.starcenter_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
 

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "starcenter" {
  load_balancer_arn = aws_alb.starcenter.id
  port              = var.starcenter_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.starcenter.id
    type             = "forward"
  }
}

#######################
##########################
#######################

resource "aws_alb_target_group" "starcenter-grafana" {
  name        = "starcenter-grafana"
  port        = var.grafana_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
 

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

#######################
##########################
#######################

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "starcenter-grafana" {
  load_balancer_arn = aws_alb.starcenter.id
  port              = var.grafana_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.starcenter-grafana.id
    type             = "forward"
  }
}
resource "aws_alb_target_group" "starcenter-prometheus" {
  name        = "starcenter-prometheus"
  port        = var.prometheus_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
 

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "starcenter-prometheus" {
  load_balancer_arn = aws_alb.starcenter.id
  port              = var.prometheus_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.starcenter-prometheus.id
    type             = "forward"
  }
}

