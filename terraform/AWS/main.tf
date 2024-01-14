# Author:           Subhayan Dasgupta
# Date Created:     11/01/2024
# Date Modified:    14/01/2024

# Description:
# Deploy an AWS EKS managed cluster using Terraform.

# Usage:
# Always use secrets.tfvars file to pass the following AWS credentials.
#
# AWS_ACCESS_KEY_ID       = "<AKIAIOSFODNN7EXAMPLE>"
# AWS_SECRET_ACCESS_KEY   = "<wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY>"
# AWS_REGION              = "<us-east-1>"
#
# Commands to deploy: 
# terraform init --var-file secrets.tfvars -upgrade
# terraform plan --var-file secrets.tfvars -out aws_eks_deployment.tfplan
# terraform apply aws_eks_deployment.tfplan
#
# Commands to destroy or clean up:
# terraform plan --var-file secrets.tfvars -destroy -out aws_eks_deployment.destroy.tfplan
# terraform apply aws_eks_deployment.destroy.tfplan

# Use AWS Terraform provider.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.32.0"
    }
  }
}

provider "aws" {
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region     = var.region
}

# Export the name of the Availability Zones (AZ)s
data "aws_availability_zones" "available" {}

# Use local values to assign names to the expressions.
locals {
  name   = "${var.name}AWSEKS"
  region = var.region

  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  public_subnets  = ["10.123.1.0/24", "10.123.2.0/24"]
  private_subnets = ["10.123.3.0/24", "10.123.4.0/24"]
  intra_subnets   = ["10.123.5.0/24", "10.123.6.0/24"]
}

# Define AWS VPC module.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  intra_subnets   = local.intra_subnets

  enable_nat_gateway = true # Enable access to the public internet.

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# Define AWS EKS module.
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.medium"] # List of instance types associated with the EKS Node Group. Defaults to ["t3.medium"]

    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    PoC-cluster-wg = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      capacity_type = "SPOT" # Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT
    }
  }

}