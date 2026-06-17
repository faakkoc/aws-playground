module "sg-069" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "ec2-allow-outbound"
  description = "Security group allowing all outbound traffic for updates"
  vpc_id      = module.vpc.vpc_id

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Alles kann raus"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
