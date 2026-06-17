module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "cluster-069"
  kubernetes_version = "1.33"

  addons = { # more addons? --> addons are installing core components
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = { # network interface, workload subnet mäßig
      before_compute = true
    }
  }

  # Optional
  endpoint_public_access = false

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets # min. 2 Subnets in 2 unterschiedlichen AZ
  # control_plane_subnet_ids = ["subnet-xyzde987", "subnet-slkjf456", "subnet-qeiru789"]

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    example = {
      # ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["c7i-flex.large"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}