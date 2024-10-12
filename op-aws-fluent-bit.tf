resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name = "${module.eks.cluster_name}-fluentbit-policy"

  description = "IAM Policy used to push logs from K8S to cloudwatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:Describe*",
          "logs:PutRetentionPolicy",
          "ec2:DescribeTags",
          "cloudwatch:PutMetricData",
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

module "fluentbit_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${module.eks.cluster_name}-fluentbit-role"

  role_policy_arns = {
    policy = aws_iam_policy.cloudwatch_logs_policy.arn
  }

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["logs:fluentbit-sa"]
    }
  }
}

resource "kubernetes_namespace" "logs" {
  metadata {
    name = "logs"
  }
}

resource "kubernetes_service_account" "fluentbit" {
  metadata {
    namespace = kubernetes_namespace.logs.id
    name      = "fluentbit-sa"
    annotations = {
      "eks.amazonaws.com/role-arn" = "${module.fluentbit_role.iam_role_arn}"
    }
  }
  automount_service_account_token = true
}

resource "helm_release" "logs" {
  chart      = "aws-for-fluent-bit"
  name       = "fluent-bit"
  namespace  = kubernetes_namespace.logs.id
  repository = "https://aws.github.io/eks-charts"

  values = [
    templatefile("${path.module}/operator-values/aws-fluent-bit.tpl", {
      service_account_name   = kubernetes_service_account.fluentbit.metadata[0].name
      create_service_account = false
      region                 = var.aws_region
      log_group_name         = "${var.application_name_prefix}/${var.env}/${var.aws_region}/fluentbit/logs"
      log_retention_days     = 30
      cluster_name           = module.eks.cluster_name
    })
  ]
}
