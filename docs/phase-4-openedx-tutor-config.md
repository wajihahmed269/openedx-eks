# Phase 4 - Open edX Tutor Configuration Audit

## Scope

This audit reviews the current Tutor configuration for deploying Open edX on EKS. It does not launch, initialize, or deploy Open edX, and it does not modify Terraform, Kubernetes, AWS, or Tutor runtime configuration.

Tutor version: `21.0.7`
Tutor root: `/home/wajih/.local/share/tutor`
Tutor Kubernetes namespace: `openedx`

## Current Config

Current non-secret Tutor settings:

```yaml
LMS_HOST: local.openedx.io
CMS_HOST: studio.local.openedx.io
MFE_HOST: apps.local.openedx.io
ENABLE_HTTPS: false
ENABLE_WEB_PROXY: true
K8S_NAMESPACE: openedx
MYSQL_HOST: openedx-eks-dev-mysql.cil8e0ae0g2o.us-east-1.rds.amazonaws.com
MYSQL_PORT: 3306
MYSQL_ROOT_USERNAME: openedx
OPENEDX_MYSQL_USERNAME: openedx
REDIS_HOST: redis-master.redis.svc.cluster.local
REDIS_PORT: 6379
PLUGINS:
  - mfe
  - indigo
```

Secrets are present in Tutor config for MySQL, Redis, Open edX, OAuth, JWT, and Meilisearch. They were not copied into this document.

Installed Tutor plugins include `minio`, but it is not enabled. Enabled plugins are currently `mfe` and `indigo`.

Rendered Kubernetes manifests currently include:

- Caddy service type `LoadBalancer` on port 80.
- LMS and CMS services as internal `ClusterIP` services on port 8000.
- MFE service as `NodePort` on port 8002.
- Open edX pods mount rendered Tutor settings/config through ConfigMaps.

No Kubernetes `Ingress` object is currently rendered by Tutor core. With `ENABLE_WEB_PROXY=true`, Tutor routes LMS/CMS through Caddy, and the rendered Caddy service is a Kubernetes `LoadBalancer` service. This is different from using the existing `ingress-nginx` controller directly.

## Target Config

The target platform should use:

- External RDS MySQL for Open edX databases.
- External Redis service in namespace `redis`.
- Private S3 bucket for Open edX media/static/uploads.
- EKS ingress path that is intentionally chosen before launch.
- Stable LMS/CMS hostnames that clients and OAuth redirects can resolve.

Current RDS settings are already pointed at the RDS endpoint. Current Redis settings are already pointed at the in-cluster Redis service FQDN.

The S3 bucket created for this environment is:

```yaml
OPENEDX_AWS_STORAGE_BUCKET_NAME: openedx-eks-dev-openedx-assets-130290477119-us-east-1
OPENEDX_AWS_S3_REGION_NAME: us-east-1
```

## Missing S3 Config

The following requested settings are missing from `/home/wajih/.local/share/tutor/config.yml`:

```yaml
OPENEDX_AWS_STORAGE_BUCKET_NAME: openedx-eks-dev-openedx-assets-130290477119-us-east-1
OPENEDX_AWS_S3_REGION_NAME: us-east-1
```

However, in Tutor 21 core, these two keys are not built-in storage settings by themselves. Core Tutor 21.0.7 defines `OPENEDX_AWS_ACCESS_KEY` and `OPENEDX_AWS_SECRET_ACCESS_KEY`, and renders those into Open edX auth config, but core Tutor does not render an S3 bucket name or region for Open edX media storage.

The installed `minio` plugin demonstrates the mechanism Tutor uses for object storage: it patches `openedx-common-settings` and related Open edX settings to set `STORAGES`, `AWS_STORAGE_BUCKET_NAME`, file upload buckets, and related `django-storages` options. That plugin is designed for MinIO or MinIO gateway behavior and should not be enabled blindly for the private AWS S3 bucket because it may add MinIO workloads and public bucket assumptions.

For AWS S3 on EKS, the safer minimal approach is:

1. Add the non-secret bucket and region values to Tutor config.
2. Add a small Tutor plugin/settings override that consumes those values and patches Open edX Django settings for S3 storage.
3. Use IRSA for pod AWS permissions, not static AWS access keys.
4. Do not set `OPENEDX_AWS_ACCESS_KEY` or `OPENEDX_AWS_SECRET_ACCESS_KEY` for AWS S3 access.

A minimal future Tutor config change would be:

```yaml
OPENEDX_AWS_STORAGE_BUCKET_NAME: openedx-eks-dev-openedx-assets-130290477119-us-east-1
OPENEDX_AWS_S3_REGION_NAME: us-east-1
```

A minimal future Open edX settings override should configure S3 storage without static credentials. Exact settings should be validated against the Open edX Teak image, but the override will likely need to set values in the same area as Tutor's `openedx-common-settings` patch, including `STORAGES["default"]`, `AWS_STORAGE_BUCKET_NAME`, `AWS_S3_REGION_NAME`, `AWS_DEFAULT_ACL = None`, and relevant upload storage buckets/prefixes.

## Ingress And Hostnames

Current hostnames are local development defaults:

```yaml
LMS_HOST: local.openedx.io
CMS_HOST: studio.local.openedx.io
MFE_HOST: apps.local.openedx.io
ENABLE_HTTPS: false
```

These can work only if DNS or local host resolution points those names to the exposed service. For EKS, the launch decision should be made before `tutor k8s launch` or `tutor k8s init`:

- Keep Tutor Caddy with `LoadBalancer`: simplest Tutor-native path, but it uses a separate AWS load balancer instead of the existing `ingress-nginx` controller.
- Use `ingress-nginx`: requires additional Tutor Kubernetes overrides or a plugin to create `Ingress` resources and avoid redundant public exposure through Caddy `LoadBalancer`.

Because ingress-nginx is already installed, the cleaner EKS target is probably to use ingress-nginx with explicit host rules for LMS, CMS, and MFE. That requires a deliberate Tutor override/plugin step before deployment.

For a real EKS launch, replace the local default hostnames with DNS names that resolve to the selected load balancer or ingress endpoint. OAuth URLs, cookies, CORS, MFE URLs, and LMS/CMS redirects depend on these values.

## Proposed Minimal Config Changes

Do not apply yet. Proposed Tutor config additions:

```diff
+OPENEDX_AWS_STORAGE_BUCKET_NAME: openedx-eks-dev-openedx-assets-130290477119-us-east-1
+OPENEDX_AWS_S3_REGION_NAME: us-east-1
```

Proposed command, only after approval:

```bash
tutor config save \
  --set OPENEDX_AWS_STORAGE_BUCKET_NAME=openedx-eks-dev-openedx-assets-130290477119-us-east-1 \
  --set OPENEDX_AWS_S3_REGION_NAME=us-east-1
```

This is not sufficient by itself to activate S3 storage in Tutor 21 core. It should be paired with a small Tutor plugin/settings override for Open edX S3 storage and an IRSA role for the Open edX Kubernetes service account.

## Risks Before Launch

- S3 settings are missing and core Tutor 21 does not consume bucket/region keys without a settings override/plugin.
- No IRSA role is configured yet for Open edX pods, so pods will not have AWS permissions to access the private S3 bucket.
- Local default hostnames are still configured; they must resolve correctly before browser/OAuth flows will work.
- `ENABLE_HTTPS=false`; cookies, OAuth redirects, and production browser behavior should be reviewed if TLS terminates at ingress.
- Tutor currently renders Caddy as a Kubernetes `LoadBalancer`, not an ingress-nginx `Ingress` resource.
- RDS init jobs may attempt database/user grants using the configured MySQL root user. Confirm that the RDS user has the required privileges before running Tutor init/launch.
- Redis password is configured in Tutor; confirm the Redis chart/service actually requires and accepts that password from Open edX pods.
- Generated Tutor env files contain secrets and should not be committed.

## Validation Commands

Read-only checks used for this audit:

```bash
tutor --version
tutor plugins list
tutor config printvalue LMS_HOST
tutor config printvalue CMS_HOST
tutor config printvalue MYSQL_HOST
tutor config printvalue REDIS_HOST
tutor config printvalue ENABLE_HTTPS
tutor config printvalue K8S_NAMESPACE
terraform -chdir=terraform/envs/dev output -raw s3_openedx_assets_bucket_name
```

Useful checks before launch, after approved config/render changes:

```bash
tutor config printvalue OPENEDX_AWS_STORAGE_BUCKET_NAME
tutor config printvalue OPENEDX_AWS_S3_REGION_NAME
grep -R "AWS_STORAGE_BUCKET_NAME\|AWS_S3_REGION_NAME\|S3Boto3Storage" ~/.local/share/tutor/env/apps/openedx/settings
kubectl get ingress,svc -n openedx
kubectl get serviceaccount -n openedx -o yaml | grep -i eks.amazonaws.com/role-arn
```
