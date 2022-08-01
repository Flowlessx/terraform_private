### APP 
resource "aws_alb" "AIM" {
  name            = "AIM"
  subnets         = aws_subnet.AIM-public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_alb_target_group" "AIM" {
  name        = "AIM"
  port        = var.AIM_frontend_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.AIM-main.id
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
resource "aws_alb_listener" "AIM" {
  load_balancer_arn = aws_alb.AIM.id
  port              = var.AIM_frontend_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.AIM.id
    type             = "forward"
  }
}

#######################
##########################
#######################

resource "aws_alb_target_group" "AIM-backend" {
  name        = "AIM-backend"
  port        = var.AIM_backend_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.AIM-main.id
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
resource "aws_alb_listener" "AIM-backend" {
  load_balancer_arn = aws_alb.AIM.id
  port              = var.AIM_backend_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.AIM-backend.id
    type             = "forward"
  }
}
#######################
##########################
#######################
