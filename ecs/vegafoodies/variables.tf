# variables.tf

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "eu-central-1"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default = "vegafoodies"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}
### Describe container images
variable "vegafoodies_frontend_image" {
  description = "Front end docker image"
  default     = "910082668725.dkr.ecr.eu-central-1.amazonaws.com/vegafoodies"
}
variable "vegafoodies_backend_image" {
  description = "Database docker image"
  default     = "910082668725.dkr.ecr.eu-central-1.amazonaws.com/vegafoodies-backend"
}

### Describe container ports
variable "app_port" {
  description = "Port exposed by the app docker image to redirect traffic to"
  default     = 80
}
### Describe container ports
variable "vegafoodies_frontend_port" {
  description = "Port exposed by the app docker image to redirect traffic to"
  default     = 80
}
### Describe container ports
variable "vegafoodies_backend_port" {
  description = "Port exposed by the app docker image to redirect traffic to"
  default     = 210
}
### Describe container ports
variable "app_port_prometheus" {
  description = "Port exposed by the app docker image to redirect traffic to"
  default     = 9090
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
  default     = 1
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

