### ECS Cluster 생성 ###
resource "aws_ecs_cluster" "ECSCluster" {
    name = "${var.tag_name}-ecs-cluster"
}

### ECS Service 생성 ###
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

resource "aws_ecs_task_definition" "ECS_Task_Def_front" {
    container_definitions = var.front_container_definitions
    family = "${var.tag_name}-front-task-1"
    execution_role_arn = var.execution_role_arn
    network_mode = var.network_mode
    requires_compatibilities = [
        var.launch_type
    ]
    cpu = var.task_def_cpu
    memory = var.task_def_memory
}

resource "aws_ecs_task_definition" "ECS_Task_Def_job" {
    container_definitions = var.job_container_definitions
    family = "${var.tag_name}-back-job-task-1"
    execution_role_arn = var.execution_role_arn
    network_mode = var.network_mode
    requires_compatibilities = [
        var.launch_type
    ]
    cpu = var.task_def_cpu
    memory = var.task_def_memory
}

resource "aws_ecs_task_definition" "ECS_Task_Def_app" {
    container_definitions = var.app_container_definitions
    family = "${var.tag_name}-back-app-task-1"
    execution_role_arn = var.execution_role_arn
    network_mode = var.network_mode
    requires_compatibilities = [
        var.launch_type
    ]
    cpu = var.task_def_cpu
    memory = var.task_def_memory
}