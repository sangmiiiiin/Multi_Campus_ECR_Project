variable "environment" {
  description = "Runtime Environment such as default, develop, stage, production"
  type        = string
}

variable "bucket_name" {
  description = "s3 bucket name"
  type        = string
}
