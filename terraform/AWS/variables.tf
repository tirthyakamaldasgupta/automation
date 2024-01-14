# Author:           Subhayan Dasgupta
# Date Created:     11/01/2024
# Date Modified:    14/01/2024

# Description:
# Hold the values for the variables which can be parameterized in main.tf.

# Usage:
# variables.tf.

variable "AWS_ACCESS_KEY_ID" {
  type        = string
  description = "Use secrets.tfvars to pass the secrets securely."
  sensitive   = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
  description = "Use secrets.tfvars to pass the secrets securely."
  sensitive   = true
}

variable "name" {
  type        = string
  description = "Use the following default string as a prefix for the AWS EKS cluster name."
  default     = "PoCKubernetesCluster"
}

variable "region" {
  type        = string
  description = "Choose a region to deploy your AWS resources." # Need User input to proceed for deployments.
}

variable "vpc_cidr" {
  type        = string
  description = "Use the following sample CIDR value for VPC"
  default     = "10.123.0.0/16"
}