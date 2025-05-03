locals {
  name_prefix = split("/", "${data.aws_caller_identity.current.arn}")[1]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  bootstrap_self_managed_addons = true

  cluster_name    = "${local.name_prefix}-eks-cluster"
  cluster_version = "1.32"

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    learner_ng = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.micro"]
      min_size       = 3
      max_size       = 3
      desired_size   = 3
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8.1"

  name                    = "${local.name_prefix}_eks_vpc"
  cidr                    = "172.31.0.0/16"
  azs                     = data.aws_availability_zones.available.names
  public_subnets          = ["172.31.101.0/24", "172.31.102.0/24"]
  private_subnets         = ["172.31.1.0/24", "172.31.2.0/24"]
  enable_nat_gateway      = true
  single_nat_gateway      = true
  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}