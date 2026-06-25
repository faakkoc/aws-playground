output "alb_dns_name" {
  description = "ALB endpoint – smoke test with: curl http://<value>/health"
  value       = module.alb.dns_name
}

output "ecr_repository_url" {
  description = "ECR URL for GitHub Actions: docker push <value>:latest"
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs – Fargate tasks run here"
  value       = module.vpc.private_subnets
}
