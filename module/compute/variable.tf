variable "region" {
  type = string
}

variable "tag_name" {
  type = string
}

variable "ami_amznlinux2" {
  type = string
}

variable "ec2_type_bastion" {
  type = string
}

variable "ava_zone" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "pub_subnet" {
  type = list(string)
}

variable "lb_type_application" {
  type = string
}

variable "bastion_sg" {
  type = string
}

variable "web_alb_sg" {
  type = string
}

variable "was_alb_sg" {
  type = string
}

variable "port_80" {
  type = string
}

variable "port_8080" {
  type = string
}

variable "port_8888" {
  type = string
}

#rds
variable "db_subnet" {
  type = list(string)
}

variable "db_pg_family" {
  type = string
}

variable "db_engine" {
  type = string
}

variable "db_engine_version" {
  type = string
}

variable "db_allocated_storage" {
  type = string
}

variable "db_instance_class" {
  type = string  
}

variable "db_username" {
  type = string  
}

variable "db_password" {
  type = string  
}

variable "db_storage_type" {
  type = string  
}

variable "db_port" {
  type = string
}

variable "db_sg" {
  type = string
}