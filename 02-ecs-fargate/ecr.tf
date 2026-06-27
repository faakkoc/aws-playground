module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "fargate-task-docker-images"

  # repository_read_write_access_arns = ["arn:aws:iam::012345678901:role/terraform"]
  repository_image_tag_mutability = "MUTABLE"
  repository_image_scan_on_push = true
  create_lifecycle_policy = false

  tags = var.tags
}