#####################################
### DESCRIBE CLUSTER
#####################################
resource "aws_kms_key" "example" {
  description             = "example"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "vegafoodies-log" {
  name = "vegafoodies-log"
}
resource "aws_ecs_cluster" "vegafoodies_cluster" {
  name = "vegafoodies-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


#####################################
### DESCRIBE TEMPLATE FILE
#####################################

### vegafoodies application [public subnet]
data "template_file" "vegafoodies" {
  template = file("./templates/ecs/vegafoodies.json.tpl")
  vars = {
    app_image      = var.vegafoodies_frontend_image
    app_port       = var.vegafoodies_frontend_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}

### vegafoodies Grafana [public subnet]
data "template_file" "vegafoodies-backend" {
  template = file("./templates/ecs/vegafoodies-backend.json.tpl")
  vars = {
    app_image      = var.vegafoodies_backend_image
    app_port       = var.vegafoodies_backend_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}

#####################################
### DESCRIBE TASK DEFINITIONS
#####################################

### vegafoodies front end app task definition
resource "aws_ecs_task_definition" "vegafoodies" {
  family                   = "vegafoodies"
  execution_role_arn       = aws_iam_role.vegafoodies_ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.vegafoodies.rendered
}

### vegafoodies front end app task definition
resource "aws_ecs_task_definition" "vegafoodies-backend" {
  family                   = "vegafoodies-backend"
  execution_role_arn       = aws_iam_role.vegafoodies_ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.vegafoodies-backend.rendered
}

#####################################
### Describe active services
#####################################

### vegafoodies front end app service
resource "aws_ecs_service" "vegafoodies" {
  name            = "vegafoodies"
  cluster         = aws_ecs_cluster.vegafoodies_cluster.id
  task_definition = aws_ecs_task_definition.vegafoodies.arn
  desired_count   = var.star_app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.vegafoodies-private.*.id
    assign_public_ip = true
  }

  service_registries {
    container_name = "vegafoodies"
    registry_arn   = aws_service_discovery_service.vegafoodies.arn
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.vegafoodies.id
    container_name   = "vegafoodies"
    container_port   = var.vegafoodies_frontend_port
  }

  depends_on = [aws_alb_listener.vegafoodies, aws_iam_role_policy_attachment.vegafoodies_ecs_task_execution_role]
}
## vegafoodies front end app service
resource "aws_ecs_service" "vegafoodies-backend" {
  name            = "vegafoodies-backend"
  cluster         = aws_ecs_cluster.vegafoodies_cluster.id
  task_definition = aws_ecs_task_definition.vegafoodies-backend.arn
  desired_count   = var.star_app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.vegafoodies-private.*.id
    assign_public_ip = false
  }

  service_registries {
    container_name = "vegafoodies-backend"
    registry_arn   = aws_service_discovery_service.vegafoodies-backend.arn
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.vegafoodies-backend.id
    container_name   = "vegafoodies-backend"
    container_port   = var.vegafoodies_backend_port
  }

 
  depends_on = [aws_alb_listener.vegafoodies-backend, aws_iam_role_policy_attachment.vegafoodies_ecs_task_execution_role]
}
