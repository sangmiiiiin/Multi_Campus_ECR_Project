locals {
  tag_name = "weplat-ap2"
}

#######################################################
## VPC                                               ##
#######################################################

module "vpc" {
  source = "./module/vpc"

  region            = "ap-northeast-2"
  cidr_main         = "10.0.0.0/16"
  tag_name          = local.tag_name
  ava_zone          = ["a", "c"]
  no                = ["1", "2", "3", "4"]
  cidr_public       = ["10.0.0.0/24", "10.0.2.0/24"]
  cidr_private      = ["10.0.4.0/24", "10.0.6.0/24"] 
  cidr_db           = ["10.0.8.0/24", "10.0.10.0/24"]
  cidr_all          = "0.0.0.0/0"
  sg_office_ip      = "211.205.9.172/32"
  protocol_tcp      = "tcp"
  protocol_all      = "-1"
  port_all          = "0"
  port_22           = "22"
  port_80           = "80"
  port_443          = "443"    
  port_8080         = "8080"
  port_8888         = "8888"
  port_3306         = "3306"
  port_3000         = "3000"
}

#######################################################
## Compute                                           ##
#######################################################

module "compute" {
  source = "./module/compute"

  region            = "ap-northeast-2"
  ava_zone          = ["a", "c"]
  tag_name          = local.tag_name
  ami_amznlinux2    = "ami-0432815cad43e4bd1"
  ec2_type_bastion  = "t3.micro"
  vpc_id            = module.vpc.vpc_id
  pub_subnet        = module.vpc.pub_subnet
  bastion_sg        = module.vpc.bastion_sg
  web_alb_sg        = module.vpc.web_alb_sg
  was_alb_sg        = module.vpc.was_alb_sg
  lb_type_application  = "application"
  port_80           = "80"
  port_8080         = "8080"
  port_8888         = "8888"

  #rds
  db_subnet = module.vpc.db_subnet
  db_pg_family = "mysql8.0"
  db_engine = "mysql"
  db_engine_version = "8.0"
  db_allocated_storage = "20"
  db_instance_class = "db.t3.medium"
  db_username = "weplat"
  db_password = "weplatweplat"
  db_storage_type = "gp3"
  db_port = "3306"
  db_sg = module.vpc.db_sg
}

#######################################################
## Container                                         ##
#######################################################

module "container" {
  source = "./module/container"

  tag_name = local.tag_name
  container_name = "weplat"
  front_arn = module.compute.aws_lb_target_group_80
  app_back_tg_arn = module.compute.aws_lb_target_group_8080
  job_back_tg_arn = module.compute.aws_lb_target_group_8888
  front_container_port = "80"
  job_container_port = "8888"
  app_container_port = "8080"
  desired_count = "2"
  launch_type = "FARGATE"
  platform_version = "LATEST"
  deployment_maximum_percent = "200"
  deployment_minimum_healthy_percent = "100"
  
  ecs_security_groups_web = module.vpc.web_ecs_sg
  ecs_security_groups_was = module.vpc.was_ecs_sg
  pri_subnet = module.vpc.pri_subnet

  assign_public_ip = "false"
  front_health_check_grace_period_seconds = "0"
  back_health_check_grace_period_seconds = "30"

  front_container_definitions = "[{\"name\":\"weplat-front\",\"image\":\"639122009176.dkr.ecr.ap-northeast-2.amazonaws.com/weplat-frontend:web\",\"cpu\":0,\"portMappings\":[{\"containerPort\":80,\"hostPort\":80,\"protocol\":\"tcp\",\"name\":\"web-80\",\"appProtocol\":\"http\"}],\"essential\":true,\"environment\":[],\"mountPoints\":[],\"volumesFrom\":[],\"logConfiguration\":{\"logDriver\":\"awslogs\",\"options\":{\"awslogs-create-group\":\"true\",\"awslogs-group\":\"/ecs/weplat-ap2-front-task-1\",\"awslogs-region\":\"ap-northeast-2\",\"awslogs-stream-prefix\":\"ecs\"}},\"systemControls\":[]}]"
  job_container_definitions = "[{\"name\":\"weplat-back-jobposting\",\"image\":\"639122009176.dkr.ecr.ap-northeast-2.amazonaws.com/weplat-backend:jobposting\",\"cpu\":0,\"portMappings\":[{\"containerPort\":8888,\"hostPort\":8888,\"protocol\":\"tcp\",\"name\":\"jobposting-8888\",\"appProtocol\":\"http\"}],\"essential\":true,\"environment\":[],\"mountPoints\":[],\"volumesFrom\":[],\"logConfiguration\":{\"logDriver\":\"awslogs\",\"options\":{\"awslogs-create-group\":\"true\",\"awslogs-group\":\"/ecs/weplat-ap2-back-job-task-1\",\"awslogs-region\":\"ap-northeast-2\",\"awslogs-stream-prefix\":\"ecs\"}},\"systemControls\":[]}]"
  app_container_definitions = "[{\"name\":\"weplat-back-applicant\",\"image\":\"639122009176.dkr.ecr.ap-northeast-2.amazonaws.com/weplat-backend:applicant\",\"cpu\":0,\"portMappings\":[{\"containerPort\":8080,\"hostPort\":8080,\"protocol\":\"tcp\",\"name\":\"applicant-8080\",\"appProtocol\":\"http\"}],\"essential\":true,\"environment\":[],\"mountPoints\":[],\"volumesFrom\":[],\"logConfiguration\":{\"logDriver\":\"awslogs\",\"options\":{\"awslogs-create-group\":\"true\",\"awslogs-group\":\"/ecs/weplat-ap2-back-app-task-1\",\"awslogs-region\":\"ap-northeast-2\",\"awslogs-stream-prefix\":\"ecs\"}},\"systemControls\":[]}]"
  execution_role_arn = "arn:aws:iam::639122009176:role/ecsTaskExecutionRole"
  network_mode = "awsvpc"
  task_def_cpu = "512"
  task_def_memory = "1024"
}


#######################################################
## backend                                         ##
#######################################################

module "backend" {
  source      = "./module/backend"
  bucket_name = "${local.tag_name}-terraform-repo-1"
  environment = "dev"
}

module "lock" {
  source          = "./module/lock"
  lock_table_name = "${local.tag_name}-terraform-lock"
  environment     = "dev"
}
