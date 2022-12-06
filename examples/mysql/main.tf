terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = ">= 4.0"
  }
}

provider "aws" {
  region = "eu-west-2"
}

data "aws_vpc" "default" {
  default = false
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "mysql" {
  source = "../../"

  name_prefix = "aurora-mysql-example"

  instance_class = "db.t4g.medium"
  replica_count  = "2"

  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.02.2"
  engine_parameter_family = "aurora-mysql8.0"

  port = 3306

  master_username = "MasterUserName"
  master_password = "MasterPassword123456"

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.all.ids

  cidr_blocks = ["10.10.10.10/32"]

  apply_immediately   = true
  skip_final_snapshot = true

  monitoring_interval = 60

  deletion_protection = false
}
