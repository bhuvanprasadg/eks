resource "aws_iam_policy" "autoscaler_policy" {
  name   = "${module.eks.cluster_name}-autoscaler-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.autoscaler_policy_doc.json
}

module "autoscaler_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${module.eks.cluster_name}-autoscaler-role"

  role_policy_arns = {
    policy = aws_iam_policy.autoscaler_policy.arn
  }

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["cluster-autoscaler:cluster-autoscaler-sa"]
    }
  }
}

resource "kubernetes_namespace" "autoscaler-ns" {
  metadata {
    name = "cluster-autoscaler"
  }
}

resource "kubernetes_service_account" "autoscaler-sa" {
  metadata {
    namespace = kubernetes_namespace.autoscaler-ns.id
    name      = "cluster-autoscaler-sa"
    annotations = {
      "eks.amazonaws.com/role-arn" = "${module.autoscaler_role.iam_role_arn}"
    }
  }
  automount_service_account_token = true
}

resource "helm_release" "autoscaler" {
  chart      = "cluster-autoscaler"
  name       = "cluster-autoscaler"
  namespace  = kubernetes_namespace.autoscaler-ns.id
  repository = "https://kubernetes.github.io/autoscaler"

  values = [
    templatefile("${path.module}/operator-values/autoscaler.tpl", {
      service_account_name   = kubernetes_service_account.autoscaler-sa.metadata[0].name
      create_service_account = false
      region                 = var.aws_region
      cluster_name           = module.eks.cluster_name
    })
  ]
}

############
# IAM Policy
############

data "aws_iam_policy_document" "autoscaler_policy_doc" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:GetInstanceTypesFromInstanceRequirements",
      "eks:DescribeNodegroup",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
    ]
  }
}