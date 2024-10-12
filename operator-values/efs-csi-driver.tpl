# Default values for aws-efs-csi-driver.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

image:
    repository: public.ecr.aws/efs-csi-driver/amazon/aws-efs-csi-driver
    tag: "v2.0.8"
    pullPolicy: IfNotPresent

controller:
    hostNetwork: false
    serviceAccount:
        create: true
        name: efs-csi-controller-sa
        eks.amazonaws.com/role-arn: ${role_name}