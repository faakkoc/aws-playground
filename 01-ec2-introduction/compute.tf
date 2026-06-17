module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "instance-069"

  ami = data.aws_ami.ubuntu.id

  instance_type = "t3.micro"
  monitoring    = true
  subnet_id     = module.vpc.private_subnets[0]
  vpc_security_group_ids = [module.sg-069.security_group_id]
  associate_public_ip_address = false

  # IAM-Rolle für SSM hinzufügen
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for SSM Session Manager"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}