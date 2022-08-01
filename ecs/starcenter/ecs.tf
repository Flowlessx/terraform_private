#####################################
### DESCRIBE CLUSTER
#####################################
resource "aws_kms_key" "starcenter" {
  description             = "starcenter"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "starcenter-log" {
  name = "starcenter-log"
}

resource "aws_ecs_cluster" "starcenter_cluster" {
  name = "starcenter-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


#####################################
### DESCRIBE TEMPLATE FILE
#####################################

### Starcenter application [public subnet]
data "template_file" "starcenter" {
  template = file("./templates/ecs/starcenter.json.tpl")
  vars = {
    app_image      = var.app_image
    app_port       = var.starcenter_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}

### Starcenter Grafana [public subnet]
data "template_file" "starcenter-grafana" {
  template = file("./templates/ecs/starcenter-grafana.json.tpl")
  vars = {
    app_image      = var.grafana_image
    app_port       = var.grafana_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}
### Starcenter Prometheus [private subnet]
data "template_file" "starcenter-prometheus" {
  template = file("./templates/ecs/starcenter-prometheus.json.tpl")
  vars = {
    app_image      = var.prometheus_image
    app_port       = var.prometheus_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}


#####################################
### DESCRIBE TASK DEFINITIONS
#####################################

### starcenter front end app task definition
resource "aws_ecs_task_definition" "starcenter" {
  family                   = "starcenter"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.starcenter.rendered
}

### starcenter front end app task definition
resource "aws_ecs_task_definition" "starcenter-grafana" {
  family                   = "starcenter-grafana"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.starcenter-grafana.rendered
}

### starcenter database [mariadb] task definition
resource "aws_ecs_task_definition" "starcenter-prometheus" {
  family                   = "starcenter-prometheus"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.starcenter-prometheus.rendered
}


#####################################
### Describe active services
#####################################

### Starcenter front end app service
resource "aws_ecs_service" "starcenter" {
  name            = "starcenter"
  cluster         = aws_ecs_cluster.starcenter_cluster.id
  task_definition = aws_ecs_task_definition.starcenter.arn
  desired_count   = var.star_app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.public.*.id
    assign_public_ip = true
  }

  service_registries {
    container_name = "starcenter"
    registry_arn   = aws_service_discovery_service.starcenter.arn
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.starcenter.id
    container_name   = "starcenter"
    container_port   = var.starcenter_port
  }

  depends_on = [aws_alb_listener.starcenter, aws_iam_role_policy_attachment.ecs_task_execution_role]
}
## Starcenter front end app service
resource "aws_ecs_service" "starcenter-grafana" {
  name            = "starcenter-grafana"
  cluster         = aws_ecs_cluster.starcenter_cluster.id
  task_definition = aws_ecs_task_definition.starcenter-grafana.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  service_registries {
    container_name = "starcenter-grafana"
    registry_arn   = aws_service_discovery_service.starcenter-grafana.arn
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.starcenter-grafana.id
    container_name   = "starcenter-grafana"
    container_port   = var.grafana_port
  }

 
  depends_on = [aws_alb_listener.starcenter-grafana, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

## Starcenter front end app service
resource "aws_ecs_service" "starcenter-prometheus" {
  name            = "starcenter-prometheus"
  cluster         = aws_ecs_cluster.starcenter_cluster.id
  task_definition = aws_ecs_task_definition.starcenter-prometheus.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  service_registries {
    container_name = "starcenter-prometheus"
    registry_arn   = aws_service_discovery_service.starcenter-prometheus.arn
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.starcenter-prometheus.id
    container_name   = "starcenter-prometheus"
    container_port   = var.prometheus_port
  }
  depends_on = [aws_alb_listener.starcenter-prometheus, aws_iam_role_policy_attachment.ecs_task_execution_role]
}
