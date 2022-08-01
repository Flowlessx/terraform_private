### APP 
resource "aws_alb" "vegafoodies" {
  name            = "vegafoodies"
  subnets         = aws_subnet.vegafoodies-public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_alb_target_group" "vegafoodies" {
  name        = "vegafoodies"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vegafoodies-main.id
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
resource "aws_alb_listener" "vegafoodies" {
  load_balancer_arn = aws_alb.vegafoodies.id
  port              = var.vegafoodies_frontend_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.vegafoodies.id
    type             = "forward"
  }
}


#######################
##########################
#######################

resource "aws_alb_target_group" "vegafoodies-backend" {
  name        = "vegafoodies-backend"
  port        = var.vegafoodies_backend_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vegafoodies-main.id
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
resource "aws_alb_listener" "vegafoodies-backend" {
  load_balancer_arn = aws_alb.vegafoodies.id
  port              = var.vegafoodies_backend_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.vegafoodies-backend.id
    type             = "forward"
  }
}
#######################
##########################
#######################
