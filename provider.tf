provider "aws" {
  region = "ap-northeast-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.45.0"
    }
  }

  # backend "s3" {
  #   dynamodb_table = "ecr-jobposting-terraform-lock"
  #   key            = "dev/terraform.tfstate"
  #   bucket         = "ecr-jobposting-terraform-repo-1"
  #   encrypt        = true
  #   region         = "ap-northeast-2"
  # }
}
