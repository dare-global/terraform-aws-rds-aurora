terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = ">= 4.0"
  }
}

provider "aws" {
  region = "eu-west-2"
}

# data "aws_vpc" "default" {
#   default = true
# }

# data "aws_subnets" "all" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.default.id]
#   }
# }

# module "postgres" {
#   source = "../../"
# }
