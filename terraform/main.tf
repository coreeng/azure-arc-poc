provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "vpc-deuw2-azure-poc"
  region = "eu-west-2"

  vpc_cidr = "192.168.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example     = local.name
    GithubRepo  = "azure-arc-poc"
    GithubOrg   = "soumentrivedi"
    environment = "demo"
    used_for    = "azure-stack-hci"
  }
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 20)]

  single_nat_gateway = true
  enable_nat_gateway = true
}
