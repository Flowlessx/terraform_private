#####################################
### DESCRIBE CLUSTER
#####################################
resource "aws_kms_key" "AIM" {
  description             = "AIM"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "AIM-log" {
  name = "AIM-log"
}

resource "aws_ecs_cluster" "AIM_cluster" {
  name = "AIM-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


#####################################
### DESCRIBE TEMPLATE FILE
#####################################

### AIM application [public subnet]
data "template_file" "AIM" {
  template = file("./templates/ecs/AIM.json.tpl")
  vars = {
    app_image      = var.app_image
    app_port       = var.AIM_frontend_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}

### AIM Backend [public subnet]
data "template_file" "AIM-backend" {
  template = file("./templates/ecs/AIM-backend.json.tpl")
  vars = {
    app_image      = var.AIM_backend_port
    app_port       = var.AIM_backend_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}

#####################################
### DESCRIBE TASK DEFINITIONS
#####################################

### AIM front end app task definition
resource "aws_ecs_task_definition" "AIM" {
  family                   = "AIM"
  execution_role_arn       = aws_iam_role.AIM-ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.AIM.rendered
}

### AIM front end app task definition
resource "aws_ecs_task_definition" "AIM-backend" {
  family                   = "AIM-backend"
  execution_role_arn       = aws_iam_role.AIM-ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.AIM-backend.rendered
}

#####################################
### Describe active services
#####################################

### AIM front end app service
resource "aws_ecs_service" "AIM" {
  name            = "AIM"
  cluster         = aws_ecs_cluster.AIM_cluster.id
  task_definition = aws_ecs_task_definition.AIM.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.AIM-public.*.id
    assign_public_ip = true
  }

  service_registries {
    container_name = "AIM"
    registry_arn   = aws_service_discovery_service.AIM.arn
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.AIM.id
    container_name   = "AIM"
    container_port   = var.AIM_frontend_port
  }
  depends_on = [aws_alb_listener.AIM, aws_iam_role_policy_attachment.AIM-ecs_task_execution_role]
}
## AIM front end app service
resource "aws_ecs_service" "AIM-backend" {
  name            = "AIM-backend"
  cluster         = aws_ecs_cluster.AIM_cluster.id
  task_definition = aws_ecs_task_definition.AIM-backend.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.AIM-private.*.id
    assign_public_ip = false
  }

  service_registries {
    container_name = "AIM-backend"
    registry_arn   = aws_service_discovery_service.AIM.arn
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.AIM-backend.id
    container_name   = "AIM-backend"
    container_port   = var.AIM_backend_port
  }

  depends_on = [aws_alb_listener.AIM-backend, aws_iam_role_policy_attachment.AIM-ecs_task_execution_role]
}

