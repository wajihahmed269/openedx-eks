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
