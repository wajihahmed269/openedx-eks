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

Planned command:

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

Verify the Ingress object:

```bash
kubectl get ingress -n ingress-test
kubectl describe ingress echo -n ingress-test
```

## Validate External Access

After the LoadBalancer hostname is available:

```bash
INGRESS_HOST=$(kubectl get svc ingress-nginx-controller \
  -n ingress-nginx \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "${INGRESS_HOST}"
curl -i "http://${INGRESS_HOST}/"
```

If the hostname is empty, wait for AWS load balancer provisioning and rerun the hostname command.

Expected result:

- HTTP response is returned through the AWS Load Balancer.
- Request reaches the NGINX Ingress Controller.
- NGINX routes the request to the `echo` Service and Pod.

## Rollback

Rollback should remove test workloads first, then remove the ingress controller and its LoadBalancer service.

Remove the test Ingress and test app namespace:

```bash
kubectl delete ingress echo -n ingress-test --ignore-not-found
kubectl delete namespace ingress-test --ignore-not-found
```

Uninstall NGINX Ingress Controller:

```bash
helm uninstall ingress-nginx -n ingress-nginx
```

Remove the controller namespace after the Helm release is gone:

```bash
kubectl delete namespace ingress-nginx --ignore-not-found
```

Verify rollback:

```bash
kubectl get namespace ingress-test ingress-nginx
kubectl get svc -A | grep ingress-nginx
```

Expected result:

- `ingress-test` namespace is gone.
- `ingress-nginx` namespace is gone.
- No `ingress-nginx-controller` Service remains.

The Helm uninstall removes the controller Service, which should also remove the AWS Load Balancer created for that Service.

## Phase 2 Boundary

Do not touch Open edX in this phase. This phase only validates ingress infrastructure with a simple test workload.
