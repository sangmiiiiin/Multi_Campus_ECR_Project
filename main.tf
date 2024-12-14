### 수정 필요 부분
# 0. local
## tag_name
## region
## account
# 1. VPC
## sg_office_ip
# 2. compute
## db_username
## db_password
## acm_arn
## host_header
## key_name
## ami_ubuntu20_04 -> 필요시 변경
# 3. container
## container_name 

locals {
  tag_name = "jinwoo-ap2"
  region   = "ap-northeast-2"
  account  = "981638470970"
}

#######################################################
## VPC                                               ##
#######################################################

module "vpc" {
  source = "./module/vpc"

  region       = local.region
  cidr_main    = "10.0.0.0/16"
  tag_name     = local.tag_name
  ava_zone     = ["a", "c"]
  no           = ["1", "2", "3", "4"]
  cidr_public  = ["10.0.0.0/24", "10.0.2.0/24"]
  cidr_private = ["10.0.4.0/24", "10.0.6.0/24"]
  cidr_db      = ["10.0.8.0/24", "10.0.10.0/24"]
  cidr_all     = "0.0.0.0/0"
  sg_office_ip = "175.200.184.33/32"
  protocol_tcp = "tcp"
  protocol_all = "-1"
  port_all     = "0"
  port_22      = "22"
  port_80      = "80"
  port_443     = "443"
  port_8080    = "8080"
  port_8888    = "8888"
  port_3306    = "3306"
  port_3000    = "3000"
}

#######################################################
## Compute                                           ##
#######################################################

module "compute" {
  source = "./module/compute"

  region              = local.region
  ava_zone            = ["a", "c"]
  tag_name            = local.tag_name
  key_name            = "jinwoo-ap2"
  host_header         = "whitehair.store"
  ami_amznlinux3      = "ami-0f1e61a80c7ab943e"
  ami_ubuntu20_04     = "ami-042e76978adeb8c48"
  acm_arn             = "arn:aws:acm:${local.region}:${local.account}:certificate/16042306-a754-4583-9bb1-c4d498e5d59f"
  ec2_type_bastion    = "t3.medium"
  vpc_id              = module.vpc.vpc_id
  pub_subnet          = module.vpc.pub_subnet
  pri_subnet          = module.vpc.pri_subnet
  bastion_sg          = module.vpc.bastion_sg
  monitoring_sg       = module.vpc.monitoring_sg
  web_alb_sg          = module.vpc.web_alb_sg
  was_alb_sg          = module.vpc.was_alb_sg
  lb_type_application = "application"
  protocol            = "HTTP"
  port_80             = "80"
  port_443            = "443"
  port_8080           = "8080"
  port_8888           = "8888"
  port_3000           = "3000"

  #rds
  db_subnet            = module.vpc.db_subnet
  db_pg_family         = "mysql8.0"
  db_engine            = "mysql"
  db_engine_version    = "8.0"
  db_allocated_storage = "20"
  db_instance_class    = "db.t3.medium"
  db_username          = "jinwoo"
  db_password          = "jinwoo1!"
  db_storage_type      = "gp3"
  db_port              = "3306"
  db_sg                = module.vpc.db_sg
}

#######################################################
## Container                                         ##
#######################################################

module "container" {
  source                             = "./module/container"
  region                             = local.region
  tag_name                           = local.tag_name
  account                            = local.account
  container_name                     = "jinwoo"
  front_arn                          = module.compute.aws_lb_target_group_80
  app_back_tg_arn                    = module.compute.aws_lb_target_group_8080
  job_back_tg_arn                    = module.compute.aws_lb_target_group_8888
  protocol_tcp                       = module.vpc.protocol_tcp
  protocol_http                      = "http"
  front_container_port               = "80"
  job_container_port                 = "8888"
  app_container_port                 = "8080"
  desired_count                      = "2"
  launch_type                        = "FARGATE"
  platform_version                   = "LATEST"
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"

  ecs_security_groups_web = module.vpc.web_ecs_sg
  ecs_security_groups_was = module.vpc.was_ecs_sg
  pri_subnet              = module.vpc.pri_subnet

  assign_public_ip                        = "false"
  front_health_check_grace_period_seconds = "0"
  back_health_check_grace_period_seconds  = "30"

  execution_role_arn = "arn:aws:iam::${local.account}:role/ecsTaskExecutionRole"
  network_mode       = "awsvpc"
  task_def_cpu       = "512"
  task_def_memory    = "1024"
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
