locals {
  eks_managed_add_on_versions = {
    coredns                = "v1.11.3-eksbuild.1"
    kube_proxy             = "v1.30.3-eksbuild.9"
    eks_pod_identity_agent = "v1.3.2-eksbuild.2"
    vpc_cni                = "v1.18.3-eksbuild.3"
  }
}

data "aws_caller_identity" "current" {}

module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "20.24.2"
  cluster_name                   = "${var.application_name_prefix}-${var.aws_region}-eks-cluster"
  cluster_version                = var.eks_cluster_version
  authentication_mode            = "API_AND_CONFIG_MAP"
  cluster_endpoint_public_access = true
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  enable_irsa                    = true
  # enable_cluster_creator_admin_permissions = true

  access_entries = {
    "admin" = {
      # principal_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS" # IAM User/Role
      principal_arn    = "arn:aws:iam::851725377193:user/bhuvanadmin"
      kubernetes_group = []

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster"
          }
        }
      }
    }
  }

  cluster_addons = {
    coredns = {
      resolve_conflicts_on_update = "OVERWRITE"
      resolve_conflicts_on_create = "OVERWRITE"
      preserve                    = true
      addon_version               = local.eks_managed_add_on_versions.coredns

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    eks-pod-identity-agent = {
      resolve_conflicts_on_update = "OVERWRITE"
      resolve_conflicts_on_create = "OVERWRITE"
      addon_version               = local.eks_managed_add_on_versions.eks_pod_identity_agent
    }
    kube-proxy = {
      addon_version               = local.eks_managed_add_on_versions.kube_proxy
      resolve_conflicts_on_update = "OVERWRITE"
      resolve_conflicts_on_create = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts_on_update = "OVERWRITE"
      resolve_conflicts_on_create = "OVERWRITE"
      before_compute              = true
      addon_version               = local.eks_managed_add_on_versions.vpc_cni
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  eks_managed_node_groups = {
    default = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["m5.large", "m5.xlarge"]
      capacity_type  = "SPOT"

      min_size             = 2
      max_size             = 5
      desired_size         = 2
      bootstrap_extra_args = <<-EOT
        # The admin host container provides SSH access and runs with "superpowers".
        # It is disabled by default, but can be disabled explicitly.
        [settings.host-containers.admin]
        enabled = false

        # The control host container provides out-of-band access via SSM.
        # It is enabled by default, and can be disabled if you do not expect to use SSM.
        # This could leave you with no way to access the API and change settings on an existing node!
        [settings.host-containers.control]
        enabled = true

        # extra args added
        [settings.kernel]
        lockdown = "integrity"
      EOT

      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }

      description = "${var.application_name_prefix}-${var.aws_region}-eks-cluster - EKS managed node group launch template"

      ebs_optimized           = true
      disable_api_termination = false
      enable_monitoring       = true

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 75
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
    }
  }

  tags = {
    terraform = "true"
    env       = var.env
    "k8s.io/cluster-autoscaler/enabled" = "true"
    "k8s.io/cluster-autoscaler/${var.application_name_prefix}-${var.aws_region}-eks-cluster" = "true"
    cloudProvider = "aws"
  }
}

resource "null_resource" "exec" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
  }
}
