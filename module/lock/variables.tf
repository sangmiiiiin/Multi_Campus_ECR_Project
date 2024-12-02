variable "environment" {
  description = "Runtime Environment such as default, develop, stage, production"
  type        = string
}

variable "lock_table_name" {
  default = "dynamo db locking table name"
  type    = string
}