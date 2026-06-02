# Phase 2 - NGINX Ingress Controller

## Goal

Prepare the EKS cluster to accept HTTP ingress traffic through NGINX Ingress Controller. Do not deploy Open edX yet.

## Architecture

```text
Internet
  -> AWS Load Balancer
  -> NGINX Ingress Controller
  -> Kubernetes Service
  -> Pod
```

The NGINX Ingress Controller runs inside Kubernetes. Its controller Service is created as type `LoadBalancer`, which asks AWS to provision an external load balancer. Ingress resources then route host/path traffic from that load balancer to Kubernetes Services and Pods.

## Safety Notes

Creating the NGINX controller LoadBalancer service can create AWS billable resources. Run the install command only after explicit approval.

This phase does not modify Terraform for the EKS cluster, VPC, IAM, node group, NAT, or subnets.

## Install NGINX Ingress Controller

Use Helm and a dedicated namespace named `ingress-nginx`.

Commands to run after approval:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer
```

## Verify Controller

```bash
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
kubectl get svc ingress-nginx-controller -n ingress-nginx -o wide
```

Expected result:

- Controller pod is Running.
- `ingress-nginx-controller` Service is type `LoadBalancer`.
- Service has an external AWS hostname in `EXTERNAL-IP` or hostname output.

Optional hostname-only command:

```bash
kubectl get svc ingress-nginx-controller \
  -n ingress-nginx \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}{"\n"}'
```

## Test App

Deploy a simple test app only after explicit approval.

Planned commands:

```bash
kubectl create namespace ingress-test

kubectl create deployment echo \
  --namespace ingress-test \
  --image=registry.k8s.io/e2e-test-images/agnhost:2.45 \
  -- /agnhost netexec --http-port=8080

kubectl expose deployment echo \
  --namespace ingress-test \
  --port=80 \
  --target-port=8080
```

## Test Ingress

Create a test Ingress only after explicit approval.

```bash
kubectl apply -n ingress-test -f - <<'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: echo
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: echo
            port:
              number: 80
EOF
```

## Validate External Access

After the LoadBalancer hostname is available:

```bash
INGRESS_HOST=$(kubectl get svc ingress-nginx-controller \
  -n ingress-nginx \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

curl -i "http://${INGRESS_HOST}/"
```

Expected result:

- HTTP response is returned through the AWS Load Balancer.
- Request reaches the NGINX Ingress Controller.
- NGINX routes the request to the `echo` Service and Pod.

## Rollback

Remove the test app resources:

```bash
kubectl delete namespace ingress-test
```

Uninstall NGINX Ingress Controller and remove its namespace:

```bash
helm uninstall ingress-nginx -n ingress-nginx
kubectl delete namespace ingress-nginx
```

The Helm uninstall removes the controller Service, which should also remove the AWS Load Balancer created for that Service.

## Phase 2 Boundary

Do not touch Open edX in this phase. This phase only validates ingress infrastructure with a simple test workload.
