# ─── ECS Cluster + Fargate Service ───────────────────────────────────────────
# The ECS module handles: ECS cluster, task definition, service, task execution
# IAM role (AmazonECSTaskExecutionRolePolicy + inline Secrets Manager statement),
# and CloudWatch log group creation.
#
# desired_count = 2 + two private subnets → ECS spreads one task per AZ by default.
# deployment_minimum_healthy_percent = 50 allows rolling deploys (one task stays
# up while the other is replaced), matching the CI/CD pipeline behaviour.
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.0"

  cluster_name = "cluster-069"

  services = {
    fargate-task = {
      cpu    = var.task_cpu
      memory = var.task_memory

      container_definitions = {
        fargate-task = {
          image     = var.container_image
          essential = true

          port_mappings = [
            {
              name          = "fargate-task"
              containerPort = var.container_port
              protocol      = "tcp"
            }
          ]

          # Log group is created and managed by the module.
          enable_cloudwatch_logging              = true
          cloudwatch_log_group_name              = "/ecs/fargate-task"
          cloudwatch_log_group_retention_in_days = 30
        }
      }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["fargate-task"].arn
          container_name   = "fargate-task"
          container_port   = var.container_port
        }
      }

      desired_count                      = var.desired_count
      deployment_minimum_healthy_percent = 50
      deployment_maximum_percent         = 200

      subnet_ids = module.vpc.private_subnets

      # Module creates the task security group using these rules.
      # Keeps SG management close to the service definition.
      security_group_rules = {
        alb_ingress = {
          type                     = "ingress"
          from_port                = var.container_port
          to_port                  = var.container_port
          protocol                 = "tcp"
          source_security_group_id = module.alb_sg.security_group_id
          description              = "Allow inbound from ALB only"
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow all outbound – NAT GW routes to ECR, Secrets Manager, CloudWatch"
        }
      }
    }
  }

  tags = var.tags
}
