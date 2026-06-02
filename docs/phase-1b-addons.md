# Phase 1B - Core EKS Add-ons

## Completed

### Metrics Server

Installed using Helm.

## Commands

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

helm upgrade --install metrics-server metrics-server/metrics-server \
  -n kube-system \
  --set args="{--kubelet-insecure-tls}"

## Verification

kubectl get pods -n kube-system
kubectl top nodes

## Result

metrics-server pod is Running.
kubectl top nodes returns CPU and memory metrics.

## EBS CSI Driver

Installed as an AWS managed EKS add-on.

Initial issue:
- Controller pods entered CrashLoopBackOff.
- Root cause was missing IRSA/OIDC configuration.
- The controller service account had no IAM role.
- The EBS plugin could not obtain AWS credentials.

Fix:
- Added IAM OIDC provider.
- Added IRSA role for ebs-csi-controller-sa.
- Attached AmazonEBSCSIDriverPolicy to the controller role.
- Passed service_account_role_arn to the aws_eks_addon resource.

Verification:

aws eks describe-addon --region us-east-1 --cluster-name openedx-eks-dev --addon-name aws-ebs-csi-driver

kubectl get pods -n kube-system | grep ebs

Result:
- Add-on status: ACTIVE
- Controller pods: 6/6 Running
