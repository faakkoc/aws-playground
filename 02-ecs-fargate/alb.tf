# ─── ALB ─────────────────────────────────────────────────────────────────────
# HTTP only for now. Next step: add ACM certificate + HTTPS listener.
# target_type = "ip" is required for Fargate (awsvpc network mode).
# create_attachment = false because ECS registers targets automatically
# through the service's load_balancer block.
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name    = "alb-069"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  security_groups = [module.alb_sg.security_group_id]

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "fargate-task"
      }
    }
  }

  target_groups = {
    fargate-task = {
      name              = "tg-x"
      protocol          = "HTTP"
      port              = var.container_port
      target_type       = "ip"
      create_attachment = false

      health_check = {
        enabled             = true
        path                = "/"
        healthy_threshold   = 2
        unhealthy_threshold = 3
        interval            = 30
        timeout             = 5
        matcher             = "200"
      }
    }
  }
  create_security_group = false
  enable_deletion_protection = false
  tags = var.tags
}
