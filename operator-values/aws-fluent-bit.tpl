
image:
  repository: public.ecr.aws/aws-observability/aws-for-fluent-bit
  tag: 2.32.2.20240516
  pullPolicy: IfNotPresent

cloudWatchLogs:
  enabled: true
  match: "*"
  region: ${region}
  logGroupName: ${log_group_name}
  logGroupTemplate: # /aws/eks/fluentbit-cloudwatch/workload/$kubernetes['namespace_name']
  logStreamPrefix: "fluentbit-"
  logStreamTemplate: # $kubernetes['pod_name'].$kubernetes['container_name']
  roleArn: 
  autoCreateGroup: true
  logRetentionDays: ${log_retention_days}

firehose:
  enabled: false

kinesis:
  enabled: false

elasticsearch:
  enabled: false

serviceAccount:
  create: false
  name: ${service_account_name}

updateStrategy:
  type: RollingUpdate


hostNetwork: false
dnsPolicy: ClusterFirst

volumes:
  - name: varlog
    hostPath:
      path: /var/log
  - name: varlibdockercontainers
    hostPath:
      path: /var/lib/docker/containers

volumeMounts:
  - name: varlog
    mountPath: /var/log
  - name: varlibdockercontainers
    mountPath: /var/lib/docker/containers
    readOnly: true

service:
  extraParsers: |
    [PARSER]
      Name   logfmt
      Format logfmt

additionalFilters: |
  [FILTER]
      Name   grep
      Match  *
      Exclude log lvl=debug*