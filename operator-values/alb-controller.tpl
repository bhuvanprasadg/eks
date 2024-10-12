# Default values for aws-load-balancer-controller.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

replicaCount: 2

revisionHistoryLimit: 5

image:
  repository: public.ecr.aws/eks/aws-load-balancer-controller
  tag: v2.7.0
  pullPolicy: IfNotPresent

autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 3
  targetCPUUtilizationPercentage: 70

serviceAccount:
  create: ${create_service_account}
  name: ${service_account_name}
  automountServiceAccountToken: true

# Time period for the controller pod to do a graceful shutdown
terminationGracePeriodSeconds: 10

priorityClassName: system-cluster-critical

updateStrategy: 
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 1

# Enable cert-manager
enableCertManager: false

# The name of the Kubernetes cluster. A non-empty value is required
clusterName: ${cluster_name}

# The ingress class this controller will satisfy. If not specified, controller will match all
# ingresses without ingress class annotation and ingresses of type alb
ingressClass: alb

# The AWS region for the kubernetes cluster. Set to use KIAM or kube2iam for example.
region: ${region}

# The VPC ID for the Kubernetes cluster. Set this manually when your pods are unable to use the metadata service to determine this automatically
vpcId: ${vpc_id}

# Default target type. Used as the default value of the "alb.ingress.kubernetes.io/target-type" and
# "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" annotations.
# Possible values are "ip" and "instance"
# The value "ip" should be used for ENI-based CNIs, such as the Amazon VPC CNI,
# Calico with encapsulation disabled, or Cilium with masquerading disabled.
# The value "instance" should be used for overlay-based CNIs, such as Calico in VXLAN or IPIP mode or
# Cilium with masquerading enabled.
defaultTargetType: instance

# Enable WAF V2 addon for ALB (default true)
enableWafv2: true

hostNetwork: false