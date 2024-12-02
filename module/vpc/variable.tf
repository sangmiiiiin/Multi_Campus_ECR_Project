variable "region" {
  type = string
}

variable "tag_name" {
  type = string
}

variable "cidr_main" {
  type = string
}

variable "ava_zone" {
  type = list(string)
}

variable "no" {
  type = list(string)
}

variable "cidr_public" {
  type = list(string)
}

variable "cidr_private" {
  type = list(string)
}

variable "cidr_db" {
  type = list(string)
}

variable "cidr_all" {
  type = string
}

variable "sg_office_ip" {
  type = string
}

variable "protocol_tcp" {
  type = string
}

variable "protocol_all" {
  type = string
}

variable "port_all" {
  type = string
}

variable "port_22" {
  type = string
}

variable "port_80" {
  type = string
}

variable "port_443" {
  type = string
}

variable "port_8080" {
  type = string
}

variable "port_8888" {
  type = string
}

variable "port_3306" {
  type = string
}

variable "port_3000" {
  type = string
}

