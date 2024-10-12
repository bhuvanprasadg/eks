## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity

autoDiscovery:
  # cloudProviders `aws`, `gce`, `azure`, `magnum`, `clusterapi` and `oci` are supported by auto-discovery at this time
  # AWS: Set tags as described in https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md#auto-discovery-setup

  # autoDiscovery.clusterName -- Enable autodiscovery for `cloudProvider=aws`, for groups matching `autoDiscovery.tags`.
  clusterName:  ${cluster_name}

  # autoDiscovery.tags -- ASG tags to match, run through `tpl`.
  tags:
    - k8s.io/cluster-autoscaler/enabled
    - k8s.io/cluster-autoscaler/{{ .Values.autoDiscovery.clusterName }}
  # - kubernetes.io/cluster/{{ .Values.autoDiscovery.clusterName }}

  # autoDiscovery.roles -- Magnum node group roles to match.
  roles:
    - worker

# hostNetwork -- Whether to expose network interfaces of the host machine to pods.
hostNetwork: false

# replicaCount -- Desired number of pods
replicaCount: 1

# awsRegion -- AWS region (required if `cloudProvider=aws`)
awsRegion: ${region}

rbac:
  create: true
  # rbac.pspEnabled -- If `true`, creates and uses RBAC resources required in the cluster with [Pod Security Policies](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) enabled.
  # Must be used with `rbac.create` set to `true`.
  pspEnabled: false
  # rbac.clusterScoped -- if set to false will only provision RBAC to alter resources in the current namespace. Most useful for Cluster-API
  clusterScoped: true
  serviceAccount:
    # rbac.serviceAccount.annotations -- Additional Service Account annotations.
    annotations: {}
    # rbac.serviceAccount.create -- If `true` and `rbac.create` is also true, a Service Account will be created.
    create: ${create_service_account}
    # rbac.serviceAccount.name -- The name of the ServiceAccount to use. If not set and create is `true`, a name is generated using the fullname template.
    name: ${service_account_name}
    # rbac.serviceAccount.automountServiceAccountToken -- Automount API credentials for a Service Account.
    automountServiceAccountToken: true