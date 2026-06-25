module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "docker"
  repository_type = "public"

  # repository_read_write_access_arns = ["arn:aws:iam::012345678901:role/terraform"]
  repository_image_tag_mutability = "MUTABLE"
  repository_image_scan_on_push = true

  tags = var.tags
}