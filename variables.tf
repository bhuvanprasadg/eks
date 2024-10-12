variable "aws_region" {
  description = "Enter the AWS region"
  default = "us-east-1"
  type = string
}

variable "application_name_prefix" {
  description = "Enter an application name or anything related to prefix with AWS service names"
  default = "sample"
  type = string
}

variable "vpc_cidr" {
  description = "Enter the VPC CIDR ranges"
  default = "10.1.0.0/16"
  type = string
}

variable "env" {
  description = "Enter the environment should be dev, uat or prod"
  default = "noenv"
  type = string
}

variable "eks_cluster_version" {
  description = "EKS Cluster version"
  default = "1.30"
}