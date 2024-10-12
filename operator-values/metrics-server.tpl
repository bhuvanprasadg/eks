# Default values for metrics-server.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

image:
  repository: registry.k8s.io/metrics-server/metrics-server
  # Overrides the image tag whose default is v{{ .Chart.AppVersion }}
  tag: ""
  pullPolicy: IfNotPresent

serviceAccount:
  # Specifies whether a service account should be created
  create: true
  # Annotations to add to the service account
  annotations: {}
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name: ""

containerPort: 10250

hostNetwork:
  # Specifies if metrics-server should be started in hostNetwork mode.
  #
  # You would require this enabled if you use alternate overlay networking for pods and
  # API server unable to communicate with metrics-server. As an example, this is required
  # if you use Calico CNI on EKS
  enabled: false

replicas: 1

revisionHistoryLimit:

updateStrategy: {}
#   type: RollingUpdate
#   rollingUpdate:
#     maxSurge: 0
#     maxUnavailable: 1

podDisruptionBudget:
  # https://kubernetes.io/docs/tasks/run-application/configure-pdb/
  enabled: true
  minAvailable: 1

livenessProbe:
  httpGet:
    path: /livez
    port: https
    scheme: HTTPS
  initialDelaySeconds: 0
  periodSeconds: 10
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /readyz
    port: https
    scheme: HTTPS
  initialDelaySeconds: 20
  periodSeconds: 10
  failureThreshold: 3

service:
  type: ClusterIP
  port: 443
  annotations: {}
  labels: {}
  #  Add these labels to have metrics-server show up in `kubectl cluster-info`
  kubernetes.io/cluster-service: "true"
  kubernetes.io/name: "Metrics-server"

metrics:
  enabled: false

# See https://github.com/kubernetes-sigs/metrics-server#scaling
resources:
  requests:
    cpu: 100m
    memory: 200Mi
  limits:
    cpu: 200m
    memory: 400Mi

tmpVolume:
  emptyDir: {}