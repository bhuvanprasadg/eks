## Argo CD configuration
## Ref: https://github.com/argoproj/argo-cd
##

crds:
  # -- Install and upgrade CRDs
  install: true

redis-ha:
  enabled: true

controller:
  replicas: 1

server:
  autoscaling:
    enabled: true
    minReplicas: 2

repoServer:
  autoscaling:
    enabled: true
    minReplicas: 2

applicationSet:
  replicas: 2