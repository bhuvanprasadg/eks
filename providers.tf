terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.46"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  shared_config_files      = ["C:/Users/bhuva/.aws/config"]
  shared_credentials_files = ["C:/Users/bhuva/.aws/credentials"]
}
