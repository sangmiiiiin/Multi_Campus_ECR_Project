variable "tag_name" {
  type = string  
}

variable "container_name" {
  type = string
}

variable "front_arn" {
  type = string
}

variable "app_back_tg_arn" {
  type = string
}

variable "job_back_tg_arn" {
  type = string
}

variable "front_container_port" {
  type = string
}

variable "job_container_port" {
  type = string
}

variable "app_container_port" {
  type = string
}

variable "desired_count" {
  type = string
}

variable "ecs_security_groups_web" {
  type = string
}

variable "ecs_security_groups_was" {
  type = string
}

variable "pri_subnet" {
  type = list(string)
}

variable "launch_type" {
  type = string
}

variable "platform_version" {
  type = string
}

variable "deployment_maximum_percent" {
  type = string
}

variable "deployment_minimum_healthy_percent" {
  type = string
}

variable "assign_public_ip" {
  type = string
}


### ECS Definition

variable "front_container_definitions" {
    type = string
}

variable "job_container_definitions" {
    type = string
}

variable "app_container_definitions" {
    type = string
}


variable "execution_role_arn" {
  type = string
}

variable "network_mode" {
  type = string
}


variable "task_def_cpu" {
  type = string
}

variable "task_def_memory" {
  type = string
}

variable "front_health_check_grace_period_seconds" {
    type = string
}

variable "back_health_check_grace_period_seconds" {
    type = string
}