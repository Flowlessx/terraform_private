# variables.tf

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "eu-central-1"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default = "myEcsTaskExecutionRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}
### Describe container images
variable "app_image" {
  description = "Front end docker image"
  default     = "910082668725.dkr.ecr.eu-central-1.amazonaws.com/starcenter"
}
variable "grafana_image" {
  description = "Database docker image"
  default     = "910082668725.dkr.ecr.eu-central-1.amazonaws.com/starcenter-grafana"
}
variable "prometheus_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "910082668725.dkr.ecr.eu-central-1.amazonaws.com/starcenter-prometheus"
}
### Describe container ports
variable "app_port" {
  description = "Port exposed by the app docker image to redirect traffic to"
  default     = 80
}
### Describe container ports
variable "starcenter_port" {
  description = "Port exposed by the app docker image to redirect traffic to"
  default     = 80
}
### Describe container ports
variable "prometheus_port" {
  description = "Port exposed by the app docker image to redirect traffic to"
  default     = 9090
}
### Describe container ports
variable "grafana_port" {
  description = "Port exposed by the app docker image to redirect traffic to"
  default     = 3000
}
### Describe container ports
variable "app_port_blue" {
  description = "Port exposed by the app docker image to redirect traffic to"
  default     = 80
}
variable "db_port" {
  description = "Port exposed by the db docker image to redirect traffic to"
  default     = 3306
}

variable "app_count" {
  description = "Number of frontend docker containers to run"
  default     = 1
}
variable "star_app_count" {
  description = "Number of frontend docker containers to run"
  default     = 2
}
variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

