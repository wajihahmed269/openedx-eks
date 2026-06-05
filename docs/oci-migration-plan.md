# OCI Migration Plan

## Context

The original Open edX assessment platform was built on AWS account `130290477119`. That account was closed after free credits ended, so the old AWS resources are no longer a reliable foundation and should not be used as a dependency for future work.

This migration keeps the existing AWS Terraform and documentation for reference, but introduces a separate OCI Terraform tree under `terraform/oci/`. AWS and OCI state must remain isolated.

## Previous AWS Architecture

The AWS environment used:

- Amazon EKS for Kubernetes.
- A VPC with public and private subnets.
- Internet Gateway for public ingress.
- NAT Gateway for private subnet egress.
- ingress-nginx with an AWS external Load Balancer service.
- AWS EBS CSI for persistent volumes.
- Amazon RDS MySQL for Open edX relational data.
- Amazon S3 for media, static assets, uploads, and object storage.
- Redis in-cluster through Helm.
- Tutor for Open edX deployment.
- A Tutor ingress plugin to keep Caddy internal and expose Open edX through ingress-nginx.

Open edX was close to working on AWS, with the remaining blocker around Meilisearch init and migration ordering.

## Target OCI Architecture

The OCI target should use low-cost services where practical:

- OCI Container Engine for Kubernetes (OKE) for the Kubernetes control plane and worker nodes.
- OCI Virtual Cloud Network (VCN) with regional public and private subnets.
- OCI Internet Gateway for public ingress.
- OCI NAT Gateway for private node egress.
- ingress-nginx as the Kubernetes ingress controller, backed by an OCI Load Balancer service.
- OCI Block Volume CSI / OKE storage classes for persistent volumes.
- Redis in-cluster through Helm.
- OCI Object Storage bucket for media, static assets, uploads, and object storage.
- MySQL choice remains a cost decision:
  - Option A: OCI MySQL HeatWave DB System if it is available and affordable in `me-jeddah-1`.
  - Option B: in-cluster MySQL for the temporary assessment if managed MySQL is too costly.
- OCI Vault may be introduced later for cloud-managed secrets. Kubernetes Secrets are acceptable temporarily for the assessment environment.

## Service Mapping

| AWS service | OCI replacement | Notes |
| --- | --- | --- |
| EKS | OKE | Use a dedicated OCI Terraform environment. |
| VPC | VCN | Use regional subnets where possible. |
| Public/private subnets | Public/private regional subnets | Public for load balancers, private for nodes and stateful services. |
| Internet Gateway | OCI Internet Gateway | Required for public ingress. |
| NAT Gateway | OCI NAT Gateway | Required for private node outbound traffic. |
| AWS Load Balancer from ingress-nginx | OCI Load Balancer service | Created by Kubernetes `Service` type `LoadBalancer`; apply only after approval. |
| EBS CSI | OCI Block Volume CSI / OKE storage class | Validate default storage class before deploying stateful workloads. |
| RDS MySQL | OCI MySQL HeatWave DB System or in-cluster MySQL | Managed MySQL must be cost-checked before provisioning. |
| S3 | OCI Object Storage bucket | Use for Open edX media/static/uploads. |
| AWS Secrets Manager | OCI Vault or Kubernetes Secret | Prefer Vault later; use Kubernetes Secret temporarily for dev. |
| Redis in-cluster | Redis in-cluster | Keep the existing low-cost pattern. |
| Tutor ingress plugin | Reuse with ingress-nginx | The plugin is cloud-neutral except for ingress controller assumptions. |

## Cost Considerations

Cost control is the main design constraint.

- Do not run `terraform apply` without explicit approval.
- OKE worker shape, node count, and boot volume size must be reviewed before creation.
- OCI Load Balancers are billable and should only be created during ingress validation.
- OCI NAT Gateway may be billable; confirm regional pricing before apply.
- OCI Object Storage is usually low cost at small assessment scale, but object volume, requests, and transfer can grow.
- OCI MySQL HeatWave DB System may be materially more expensive than temporary in-cluster MySQL. Confirm shape availability and monthly estimate before choosing managed MySQL.
- In-cluster Redis and in-cluster MySQL reduce managed service cost but consume OKE node CPU, memory, and persistent storage.

## Risks

- OKE service limits or regional availability in `me-jeddah-1` may restrict node shapes, node counts, load balancers, or MySQL DB Systems.
- Managed MySQL cost may exceed the assessment budget.
- In-cluster MySQL is operationally weaker than managed MySQL and should be treated as temporary.
- Tutor/Open edX deployment ordering still needs attention for Meilisearch initialization and migrations.
- OCI Object Storage compatibility with the Open edX/Tutor configuration must be validated, including endpoint format, credentials, and bucket policy.
- DNS and TLS are not included in the first scaffold and will need a separate plan.

## Implementation Order

### Phase OCI-1

- Configure the OCI Terraform provider using OCI CLI/profile authentication.
- Create a VCN.
- Create public and private regional subnets.
- Create an Internet Gateway.
- Create a NAT Gateway.
- Create route tables and security controls.

### Phase OCI-2

- Create an OKE cluster.
- Create a minimal node pool.
- Generate or retrieve kubeconfig.
- Validate with `kubectl get nodes`.

### Phase OCI-3

- Install ingress-nginx after approval.
- Validate the OCI Load Balancer service.
- Validate the default storage class or OCI Block Volume CSI behavior.
- Install Redis with Helm after approval.

### Phase OCI-4

- Create an OCI Object Storage bucket.
- Decide MySQL path:
  - Use OCI MySQL HeatWave DB System only if cost and availability are acceptable.
  - Otherwise use temporary in-cluster MySQL for the assessment.

### Phase OCI-5

- Update Tutor configuration for OCI endpoints and Kubernetes services.
- Reuse the Tutor ingress plugin where possible.
- Retry Open edX deployment and handle Meilisearch/migration ordering.

## Rollback And Cleanup Notes

- Keep AWS and OCI Terraform state separate.
- Do not run broad destroy commands casually.
- Before deleting object storage, confirm whether the bucket contains Open edX media or uploads that need backup.
- Before deleting databases or persistent volumes, export required data and confirm no workload depends on them.
- For pre-apply rollback, remove only the new OCI scaffold files if they are no longer wanted.
- For post-apply cleanup, use targeted Terraform plans and review each billable resource before destruction.

## Tutor And Open edX Continuity

The Tutor deployment model remains mostly unchanged:

- Tutor still generates Open edX Kubernetes manifests.
- Caddy should remain internal as a ClusterIP service.
- ingress-nginx should remain the single public entry point.
- Redis can stay in-cluster.
- The existing Tutor ingress plugin appears reusable because it targets Kubernetes and ingress-nginx rather than AWS-specific APIs.

Cloud-specific changes are expected around object storage endpoints, database connectivity, secrets, DNS, TLS, and storage classes.
