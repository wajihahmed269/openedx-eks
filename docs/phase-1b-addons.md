# Phase 1B - Core EKS Add-ons

## Goal

Install and verify the core Kubernetes add-ons needed before deploying Open edX workloads on EKS.

## Metrics Server

Metrics Server was installed with Helm into the existing `kube-system` namespace.

```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

helm upgrade --install metrics-server metrics-server/metrics-server \
  -n kube-system \
  --set args="{--kubelet-insecure-tls}"
```

The `--kubelet-insecure-tls` flag was used for this assessment environment so Metrics Server can scrape kubelet metrics successfully.

### Metrics Server Verification

```bash
kubectl get pods -n kube-system
```

Successful output included:

```text
metrics-server-74c6bc5757-vn9vs       1/1     Running   0          64m
```

```bash
kubectl top nodes
```

Successful output:

```text
NAME                          CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
ip-10-0-12-190.ec2.internal   41m          2%       887Mi           28%
```

## EBS CSI Driver

The AWS EBS CSI Driver was installed as an AWS managed EKS add-on using Terraform `aws_eks_addon`.

The final Terraform configuration includes:

- An IAM OIDC provider for the EKS cluster issuer.
- A dedicated IRSA IAM role for `system:serviceaccount:kube-system:ebs-csi-controller-sa`.
- `AmazonEBSCSIDriverPolicy` attached to the EBS CSI controller role.
- `service_account_role_arn` set on the `aws_eks_addon` resource.

## Initial EBS CSI Failure

The initial add-on creation got stuck with AWS showing the add-on in `CREATING` state.

Observed Kubernetes symptoms:

- `ebs-csi-node` pod was Running.
- `ebs-csi-controller` pods were in `CrashLoopBackOff`.
- Controller pods were only `1/6` ready.
- Liveness and readiness probes failed.
- CSI sidecars restarted because they could not connect to the CSI socket.

The key controller log showed the EBS plugin could not obtain AWS credentials:

```text
Failed health check (verify network connection and IAM credentials): dry-run EC2 API call failed: operation error EC2: DescribeAvailabilityZones, get identity: get credentials: failed to refresh cached credentials, no EC2 IMDS role found
```

## Root Cause

The EBS CSI controller did not have production-style IRSA configured.

The missing pieces were:

- No IAM OIDC provider for the EKS cluster issuer.
- No IAM role trusted by the EBS CSI controller Kubernetes service account.
- No `service_account_role_arn` on the managed EKS add-on.

Attaching `AmazonEBSCSIDriverPolicy` to the worker node IAM role was not sufficient for the controller pod in this cluster state. The controller needed its own service-account-scoped IAM role so the managed add-on could annotate and run `ebs-csi-controller-sa` with web identity credentials.

## Fix

Terraform was updated to add the missing IRSA configuration:

- `aws_iam_openid_connect_provider.this`
- `aws_iam_role.ebs_csi_controller`
- `aws_iam_role_policy_attachment.ebs_csi_controller_policy`
- `service_account_role_arn = aws_iam_role.ebs_csi_controller.arn` on `aws_eks_addon.ebs_csi`

The trust policy is scoped to this Kubernetes subject:

```text
system:serviceaccount:kube-system:ebs-csi-controller-sa
```

## EBS CSI Verification

```bash
aws eks describe-addon \
  --region us-east-1 \
  --cluster-name openedx-eks-dev \
  --addon-name aws-ebs-csi-driver
```

Successful output included:

```json
{
  "addon": {
    "addonName": "aws-ebs-csi-driver",
    "clusterName": "openedx-eks-dev",
    "status": "ACTIVE",
    "addonVersion": "v1.60.1-eksbuild.1",
    "health": {
      "issues": []
    },
    "serviceAccountRoleArn": "arn:aws:iam::130290477119:role/openedx-eks-dev-ebs-csi-controller-role"
  }
}
```

```bash
kubectl get pods -n kube-system
```

Successful output included:

```text
ebs-csi-controller-58844846bd-4682r   6/6     Running   0          9m30s
ebs-csi-controller-58844846bd-jdqjq   6/6     Running   0          9m30s
ebs-csi-node-6v4lm                    3/3     Running   0          9m30s
```

```bash
kubectl get storageclass
```

Successful output:

```text
NAME   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
gp2    kubernetes.io/aws-ebs   Delete          WaitForFirstConsumer   false                  113m
```

## Current Phase 1B Status

Phase 1B is complete:

- Metrics Server is installed and returning node metrics.
- EBS CSI managed add-on is `ACTIVE`.
- EBS CSI controller pods are `6/6 Running`.
- EBS CSI node pod is Running.
- `gp2` StorageClass exists.
