### ECS Cluster 생성 ###
resource "aws_ecs_cluster" "ECSCluster" {
    name = "${var.tag_name}-ecs-cluster"
    setting {
      name  = "containerInsights"
      value = "enabled"
  }
}

### ECS Front Service
resource "aws_ecs_service" "ECS_Service_front" {
    name = "${var.tag_name}-front-service"
    cluster = aws_ecs_cluster.ECSCluster.arn
    load_balancer {
        target_group_arn = var.front_arn
        container_name = "${var.container_name}-front"
        container_port = var.front_container_port
    }
    desired_count = var.desired_count
    launch_type = var.launch_type
    platform_version = var.platform_version
    task_definition = aws_ecs_task_definition.ECS_Task_Def_front.arn
    deployment_maximum_percent = var.deployment_maximum_percent
    deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
    network_configuration {
        assign_public_ip = var.assign_public_ip
        security_groups = [var.ecs_security_groups_web]
        subnets = var.pri_subnet
    }
    health_check_grace_period_seconds = var.front_health_check_grace_period_seconds
}

### ECS Backend Service 생성 ###
### JobPosting ###
resource "aws_ecs_service" "ECS_Service_job" {
    name = "${var.tag_name}-back-job-service"
    cluster = aws_ecs_cluster.ECSCluster.arn
    load_balancer {
        target_group_arn = var.job_back_tg_arn
        container_name = "${var.container_name}-back-jobposting"
        container_port = var.job_container_port
    }
    desired_count = var.desired_count
    launch_type = var.launch_type
    platform_version = var.platform_version
    task_definition = aws_ecs_task_definition.ECS_Task_Def_job.arn
    deployment_maximum_percent = var.deployment_maximum_percent
    deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
    network_configuration {
        assign_public_ip = var.assign_public_ip
        security_groups = [var.ecs_security_groups_was]
        subnets = var.pri_subnet
    }
    health_check_grace_period_seconds = var.back_health_check_grace_period_seconds
}

### Applicant ###
resource "aws_ecs_service" "ECS_Service_app" {
    name = "${var.tag_name}-back-app-service"
    cluster = aws_ecs_cluster.ECSCluster.arn
    load_balancer {
        target_group_arn = var.app_back_tg_arn
        container_name = "${var.container_name}-back-applicant"
        container_port = var.app_container_port
    }
    desired_count = var.desired_count
    launch_type = var.launch_type
    platform_version = var.platform_version
    task_definition = aws_ecs_task_definition.ECS_Task_Def_app.arn
    deployment_maximum_percent = var.deployment_maximum_percent
    deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
    network_configuration {
        assign_public_ip = var.assign_public_ip
        security_groups = [var.ecs_security_groups_was]
        subnets = var.pri_subnet
    }
    health_check_grace_period_seconds = var.back_health_check_grace_period_seconds
}

### ECS Task 정의 생성 ###
### Front ###
resource "aws_ecs_task_definition" "ECS_Task_Def_front" {
    
    container_definitions    = jsonencode([
    {
      name            = "${var.container_name}-front"
      image           = "${var.account}.dkr.ecr.${var.region}.amazonaws.com/${var.container_name}-frontend:web"
      cpu             = 0
      essential       = true
      portMappings    = [
        {
          containerPort = tonumber(var.front_container_port) # 숫자로 변환
          hostPort      = tonumber(var.front_container_port) # 숫자로 변환
          protocol      = var.protocol_tcp
          name          = "web-${var.front_container_port}"
          appProtocol   = var.protocol_http
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group = "true"
          awslogs-group        = "/ecs/${var.tag_name}-front-task-1"
          awslogs-region       = "${var.region}"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

    family = "${var.tag_name}-front-task-1"
    execution_role_arn = var.execution_role_arn
    network_mode = var.network_mode
    requires_compatibilities = [
        var.launch_type
    ]
    cpu = var.task_def_cpu
    memory = var.task_def_memory
}

### Backend Jobposting ###
resource "aws_ecs_task_definition" "ECS_Task_Def_job" {

### Backend Jobposting ###


    container_definitions    = jsonencode([
    {
      name            = "${var.container_name}-back-jobposting"
      image           = "${var.account}.dkr.ecr.${var.region}.amazonaws.com/${var.container_name}-backend:jobposting"
      cpu             = 0
      essential       = true
      portMappings    = [
        {
          containerPort = tonumber(var.job_container_port)
          hostPort      = tonumber(var.job_container_port)
          protocol      = var.protocol_tcp
          name          = "jobposting-${var.job_container_port}"
          appProtocol   = var.protocol_http
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group = "true"
          awslogs-group        = "/ecs/${var.tag_name}-back-job-task-1"
          awslogs-region       = "${var.region}"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
    family = "${var.tag_name}-back-job-task-1"
    execution_role_arn = var.execution_role_arn
    network_mode = var.network_mode
    requires_compatibilities = [
        var.launch_type
    ]
    cpu = var.task_def_cpu
    memory = var.task_def_memory
}

### Backend Applicant ###
resource "aws_ecs_task_definition" "ECS_Task_Def_app" {

    container_definitions    = jsonencode([
    {
      name            = "${var.container_name}-back-applicant"
      image           = "${var.account}.dkr.ecr.${var.region}.amazonaws.com/${var.container_name}-backend:applicant"
      cpu             = 0
      essential       = true
      portMappings    = [
        {
          containerPort = tonumber(var.app_container_port)
          hostPort      = tonumber(var.app_container_port)
          protocol      = var.protocol_tcp
          name          = "applicant-${var.app_container_port}"
          appProtocol   = var.protocol_http
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group = "true"
          awslogs-group        = "/ecs/${var.tag_name}-back-app-task-1"
          awslogs-region       = "${var.region}"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
    family = "${var.tag_name}-back-app-task-1"
    execution_role_arn = var.execution_role_arn
    network_mode = var.network_mode
    requires_compatibilities = [
        var.launch_type
    ]
    cpu = var.task_def_cpu
    memory = var.task_def_memory
}

# 오토스케일링 타겟 설정
resource "aws_appautoscaling_target" "ecs_scaling_target" {
  for_each           = toset(var.services)
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.ECSCluster.name}/${each.key}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 5
}

# CPU 기반 스케일링 정책
resource "aws_appautoscaling_policy" "ecs_scaling_policy_cpu" {
  for_each           = toset(var.services)
  name               = "${each.key}-cpu-scaling-policy"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ecs_scaling_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_scaling_target[each.key].scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = 50.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

# 메모리 기반 스케일링 정책 (선택 사항)
resource "aws_appautoscaling_policy" "ecs_scaling_policy_memory" {
  for_each           = toset(var.services)
  name               = "${each.key}-memory-scaling-policy"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ecs_scaling_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_scaling_target[each.key].scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = 75.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}