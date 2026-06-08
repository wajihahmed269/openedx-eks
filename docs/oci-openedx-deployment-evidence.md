# OCI Open edX Deployment Evidence

## Environment
- OCI region: `me-jeddah-1`
- Compartment: `phoenix-ops`
- OKE cluster: `BASIC`, `ACTIVE`
- Node shape: `VM.Standard.E5.Flex`
- Worker node: `10.20.20.135`
- Ingress controller IP: `141.147.133.86`

## Architecture
- Public/API subnet for the Kubernetes API endpoint
- Private worker subnet for the OKE node
- NAT gateway for private egress
- `ingress-nginx` provides external HTTP ingress
- Tutor Caddy remains `ClusterIP`
- LMS and CMS are routed through `openedx-web` to `caddy:80`

## Hostnames
- `local.openedx.io`
- `studio.local.openedx.io`
- `apps.local.openedx.io`

## Fixed Items
- OKE worker networking rules were completed so the node could register
- Tutor config was cleaned of dead AWS RDS/S3 dependencies
- `RUN_MYSQL=true` and `RUN_REDIS=true` were enabled for in-cluster services
- `ingress-nginx` was installed
- `/etc/hosts` was updated locally for the three hostnames above

## Commands Used
- `kubectl get nodes -o wide`
- `kubectl get pods -A`
- `kubectl get ingress -n openedx`
- `kubectl get svc -A`
- `kubectl get jobs -n openedx`
- `kubectl get pvc -n openedx`
- `kubectl get events -n openedx --sort-by=.metadata.creationTimestamp | tail -80`
- `tutor config save`
- `tutor k8s start`
- `tutor k8s init`
- `curl -I -H 'Host: ...' http://141.147.133.86/`

## Validation Results
- LMS returned `HTTP/1.1 200 OK`
- Studio returned `HTTP/1.1 302 Found`
- `apps.local.openedx.io` resolved for browser use; direct `curl -I` to `/` returned `HTTP/1.1 404 Not Found`
- `openedx-web` ingress is present and bound to `141.147.133.86`
- Open edX core pods are running in `openedx`
- All init jobs completed successfully

## Current Cluster State
- `caddy`, `cms`, `lms`, `mfe`, `mysql`, `redis`, `mongodb`, `meilisearch`, and `smtp` are running
- `ingress-nginx` controller is running
- PVCs for `caddy`, `meilisearch`, `mongodb`, `mysql`, and `redis` are bound

## Remaining Manual Screenshot Checklist
- LMS home page at `http://local.openedx.io`
- Studio home page at `http://studio.local.openedx.io`
- Browser access with `apps.local.openedx.io` working in the address bar
- `kubectl get pods -n openedx -o wide`
- `kubectl get ingress -n openedx`
- `kubectl get svc -n ingress-nginx`

