# Phase 4 - Tutor Ingress-NGINX Integration Plan

## Scope

This document audits Tutor's Kubernetes exposure model and proposes a plan to use the existing ingress-nginx controller as the external entry point for Open edX on EKS.

No Tutor config, Tutor plugin, generated Tutor env file, Kubernetes resource, AWS resource, or Terraform file was changed as part of this audit.

## Current Exposure Model

Rendered Tutor Kubernetes service file:

```text
/home/wajih/.local/share/tutor/env/k8s/services.yml
```

Current rendered Caddy service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: caddy
  labels:
    app.kubernetes.io/name: caddy
    app.kubernetes.io/component: loadbalancer
spec:
  type: LoadBalancer
  ports:
    - port: 80
      name: http
  selector:
    app.kubernetes.io/name: caddy
```

If applied as-is, this service would ask AWS to create a second external LoadBalancer for Tutor Caddy. That conflicts with the preferred architecture because ingress-nginx already has an AWS LoadBalancer.

Other relevant rendered services:

```yaml
cms: ClusterIP port 8000
lms: ClusterIP port 8000
mfe: NodePort port 8002
```

Rendered Caddy routes hostnames to internal services:

```text
local.openedx.io            -> lms:8000
studio.local.openedx.io     -> cms:8000
apps.local.openedx.io       -> mfe:8002
meilisearch.local.openedx.io -> meilisearch:7700
```

Current Tutor plugin root:

```text
/home/wajih/.local/share/tutor-plugins
```

That directory does not currently exist.

## Preferred Architecture

Target request path:

```text
Internet
-> existing AWS LoadBalancer from ingress-nginx
-> ingress-nginx
-> Tutor Caddy service as ClusterIP
-> Open edX services
```

Caddy should remain in the request path because Tutor already renders Caddy host-based routing and Open edX-specific reverse proxy behavior. ingress-nginx should be the only Kubernetes service that owns an external AWS LoadBalancer.

## Tutor 21 Patch Points

Tutor 21 core renders `k8s/services.yml` from:

```text
/home/wajih/.local/share/pipx/venvs/tutor/lib/python3.12/site-packages/tutor/templates/k8s/services.yml
```

The relevant template behavior is:

```jinja
{% if ENABLE_WEB_PROXY %}
...
spec:
  type: LoadBalancer
...
{% else %}
...
spec:
  type: ClusterIP
...
{% endif %}
...
{{ patch("k8s-services") }}
```

Setting `ENABLE_WEB_PROXY=false` would make Tutor render the Caddy service as `ClusterIP`, but it also changes Caddy deployment behavior and disables Tutor's normal web-proxy mode assumptions. That is too broad for this goal.

Tutor also renders `k8s/override.yml` from:

```jinja
{{ patch("k8s-override") }}
```

And wires it into Kustomize when populated:

```yaml
patches:
- path: k8s/override.yml
```

This is the cleanest Tutor 21-compatible way to change the built-in Caddy service without directly editing generated files: create a small Tutor plugin that supplies a strategic-merge patch through `k8s-override`.

For adding new Kubernetes resources such as `Ingress`, Tutor's `k8s-services` patch point is appropriate because it appends additional YAML resources to `k8s/services.yml` during render.

## Recommended Implementation Method

Use a Tutor plugin patch, not manual edits to generated Tutor env files.

Why:

- Generated files under `~/.local/share/tutor/env` are render artifacts and can be overwritten by `tutor config save` or future render operations.
- Tutor plugin patches are compatible with Tutor's render model and can use Tutor config variables such as `LMS_HOST` and `CMS_HOST`.
- A plugin keeps the ingress/Caddy integration reproducible before `tutor k8s launch`.

A repo-managed Kubernetes overlay could also work, but it would sit outside Tutor's render lifecycle. That makes drift more likely unless the deployment workflow always runs Tutor render first and then applies a separate repo overlay. For this assessment, the plugin path is cleaner.

## Proposed Future Tutor Plugin

Do not create or enable this yet. Proposed plugin path after approval:

```text
/home/wajih/.local/share/tutor-plugins/openedx_eks_ingress.py
```

Proposed plugin content:

```python
from tutor import hooks

hooks.Filters.ENV_PATCHES.add_items(
    [
        (
            "k8s-override",
            """
---
apiVersion: v1
kind: Service
metadata:
  name: caddy
spec:
  type: ClusterIP
""",
        ),
        (
            "k8s-services",
            """
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: openedx-web
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "250m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "120"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "120"
spec:
  ingressClassName: nginx
  rules:
    - host: {{ LMS_HOST }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: caddy
                port:
                  number: 80
    - host: {{ CMS_HOST }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: caddy
                port:
                  number: 80
""",
        ),
    ]
)
```

Expected rendered effect:

```diff
 apiVersion: v1
 kind: Service
 metadata:
   name: caddy
 spec:
-  type: LoadBalancer
+  type: ClusterIP
   ports:
     - port: 80
       name: http
```

Expected additional rendered resource:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: openedx-web
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "250m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "120"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "120"
spec:
  ingressClassName: nginx
  rules:
    - host: local.openedx.io
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: caddy
                port:
                  number: 80
    - host: studio.local.openedx.io
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: caddy
                port:
                  number: 80
```

## Optional MFE Service Patch

The enabled MFE plugin currently appends an `mfe` service of type `NodePort`. This does not create a second AWS LoadBalancer, but it does expose a node port on worker nodes. Because Caddy already proxies `apps.local.openedx.io` to `mfe:8002`, a stricter internal-only model would also patch MFE to `ClusterIP`.

Optional future `k8s-override` addition:

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: mfe
spec:
  type: ClusterIP
```

This should be validated against the MFE plugin's expectations before applying. It is not required to prevent a second AWS LoadBalancer.

## Hostname Decision

Current Tutor hostnames are still local defaults:

```yaml
LMS_HOST: local.openedx.io
CMS_HOST: studio.local.openedx.io
MFE_HOST: apps.local.openedx.io
ENABLE_HTTPS: false
```

For a real EKS launch, these hostnames must resolve to the existing ingress-nginx AWS LoadBalancer. Options:

- Keep local hostnames for a controlled test and map them manually through `/etc/hosts` or local DNS to the ingress-nginx LoadBalancer hostname/IP.
- Replace them with real DNS names before launch, then point DNS records at ingress-nginx.

Changing hostnames after Open edX initialization can affect OAuth clients, cookies, CORS, MFE URLs, and site configuration. The hostname decision should be finalized before `tutor k8s init` or `tutor k8s launch`.

## HTTPS/TLS Decision

Current Tutor config has:

```yaml
ENABLE_HTTPS: false
```

If TLS terminates at ingress-nginx, there are two follow-up decisions:

1. Configure ingress-nginx TLS on the `Ingress` resource.
2. Set Tutor/Open edX HTTPS-related config consistently so generated OAuth URLs, root URLs, cookies, and forwarded headers are correct.

This plan intentionally does not add TLS yet. For a first internal validation, HTTP through ingress-nginx is simpler. For any public or production-like launch, TLS should be added before user testing.

## Validation Plan After Approval

After approval to create and enable the plugin, but before launch/init:

```bash
tutor plugins enable openedx_eks_ingress
tutor config save
```

Then inspect rendered output only:

```bash
grep -n "name: caddy\|type: LoadBalancer\|type: ClusterIP" ~/.local/share/tutor/env/k8s/services.yml
grep -R "kind: Ingress\|name: openedx-web\|ingressClassName: nginx" ~/.local/share/tutor/env/k8s
```

Expected checks:

```text
caddy service type is ClusterIP
no caddy service type LoadBalancer remains
Ingress openedx-web exists
Ingress rules point LMS and CMS hosts to service caddy port 80
```

If rendering is correct, only then consider launch/init in a separate approved step.

## Risks And Notes

- Do not manually edit `~/.local/share/tutor/env/k8s/services.yml`; it is generated and will be overwritten.
- The `k8s-services` patch can add new resources, but replacing the built-in Caddy service is better handled by `k8s-override`/Kustomize patching.
- The plugin root path does not exist yet and would need to be created before adding a local plugin.
- ingress-nginx must have an active ingress class named `nginx` for `ingressClassName: nginx` to bind correctly.
- Caddy must receive the original `Host` header so its host-based routes match LMS/CMS/MFE hostnames. ingress-nginx preserves host headers by default.
- The current Caddy service has a `loadbalancer` component label. The proposed patch changes only `spec.type`; the stale label is harmless but can be cleaned up in a fuller custom service replacement if needed.
- The existing MFE `NodePort` does not create another AWS LoadBalancer, but it may be worth converting to `ClusterIP` for a stricter internal-only model.
