locals {
  azs  = ["${var.region}a", "${var.region}b"]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-069"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = var.tags
}
