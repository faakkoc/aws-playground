variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}


variable "container_image" {
  description = "Container image URI – placeholder until CI/CD pushes to ECR"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 8000
}

variable "task_cpu" {
  description = "vCPU units for the Fargate task (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory in MB for the Fargate task"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of Fargate tasks – 2 ensures one per AZ for HA"
  type        = number
  default     = 2
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}
