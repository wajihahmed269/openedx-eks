# Phase 3 - Stateful Data Layer Plan

## Goal

Phase 3 builds the stateful data layer required before deploying Open edX workloads on EKS.

This phase prepares the services that Open edX will depend on for relational data, cache/session-style data, and object storage. The planned data layer is:

- MySQL on AWS RDS, managed with Terraform.
- S3 bucket for media, static assets, uploads, and object storage, managed with Terraform.
- Redis running in-cluster initially with Helm.
- OpenSearch skipped initially.
- MongoDB skipped unless Tutor/Open edX confirms it is required for this deployment path.

## Target Architecture

```text
Open edX pods on EKS
  -> RDS MySQL private endpoint
  -> Redis service inside Kubernetes
  -> S3 bucket for media/static/object storage
```

RDS and S3 should be provisioned with Terraform. Redis should be installed with Helm only after the Terraform-backed data dependencies are reviewed and approved.

## RDS MySQL Design

RDS MySQL should run as a private database dependency for Open edX.

Requirements:

- Place RDS in private subnets only.
- Set `publicly_accessible = false`.
- Create a DB subnet group from the private subnet IDs.
- Create a security group that allows MySQL `3306` only from the EKS worker/node security group or a future application security group.
- Enable encryption at rest.
- Enable backup retention, even in dev, so accidental data loss has some recovery path.
- Use deletion protection later for production; it can remain disabled in dev to keep cleanup straightforward.
- Use a small dev instance class for cost control.
- Do not hardcode database credentials in Terraform variables, committed files, or Kubernetes manifests.
- Store credentials in AWS Secrets Manager later, then wire workloads to those secrets through a production-style integration.

Initial dev sizing should prioritize low cost over high availability. Production sizing, Multi-AZ, read replicas, deletion protection, longer retention, and maintenance windows can be added later.

## S3 Design

S3 will provide object storage for Open edX media, static files, uploads, and similar artifacts.

Requirements:

- Create a dedicated bucket for Open edX object storage.
- Block public access by default.
- Enable server-side encryption.
- Consider versioning, especially for production or long-lived environments.
- Access should later use IAM/IRSA from Open edX workloads, not static AWS access keys.
- Add CloudFront later if public asset delivery or CDN behavior is needed.

The initial bucket should be private and conservative. Public access should only be introduced deliberately through a reviewed CDN or signed-access pattern.

## Redis Design

Redis will run in-cluster initially using Helm.

Initial requirements:

- Use a dedicated namespace, probably `redis`.
- Expose Redis with a `ClusterIP` service only.
- Do not expose Redis publicly.
- Persistence is optional for dev.
- Use node resources carefully, since Redis will consume EKS worker capacity.

Migration path:

- Start with in-cluster Redis for speed and assessment simplicity.
- Move to ElastiCache later if the deployment needs managed Redis operations, better durability, scaling, backups, or production isolation.

## Security Group Strategy

Phase 3 introduces a reusable `terraform/modules/security-group` module before creating RDS or other stateful services. This keeps network policy centralized, repeatable, and easier to audit as the assessment grows.

Security group design should stay reusable and explicit.

Recommendations:

- Create `terraform/modules/security-group` or establish reusable security group patterns before adding database resources.
- Avoid scattering inline security group rules across unrelated Terraform resources.
- Keep RDS inbound rules tightly restricted.
- Allow MySQL `3306` only from the EKS worker/node security group or a future app-specific security group.
- Do not allow database access from `0.0.0.0/0`.
- Do not make databases publicly accessible.

The goal is to make future changes easy to audit: database access should be visible in a small number of Terraform resources.

Future RDS networking flow:

```text
Open edX pod
  -> Kubernetes Service/app networking
  -> EKS node or application security group
  -> RDS security group inbound 3306
  -> RDS MySQL private endpoint in private subnets
```

Databases must remain private because they hold application state, credentials-derived data, user data, and operational metadata. Public database endpoints increase attack surface and make access control depend too heavily on passwords alone. The safer pattern is private subnet placement plus security group allowlists from known application infrastructure.

## Secrets Strategy

There are two practical options for early wiring.

### Kubernetes Secret

A Kubernetes Secret is fast for dev and simple to reference from workloads.

Tradeoffs:

- Easier to create and debug.
- Good enough for temporary local assessment wiring.
- Not ideal as the long-term source of truth for cloud-managed credentials.

### AWS Secrets Manager

AWS Secrets Manager is a better production-style home for database credentials and other cloud secrets.

Tradeoffs:

- Better integration with IAM and cloud audit trails.
- Can support rotation patterns later.
- Needs an integration layer such as External Secrets Operator, Secrets Store CSI Driver, or app-level AWS SDK access through IRSA.

### Recommendation

Start with a Kubernetes Secret only for temporary dev wiring. Move to AWS Secrets Manager plus External Secrets or IRSA later before treating the environment as production-like.

Do not commit secret values to the repository.

## Rollback And Destroy Strategy

Use a safe dependency-aware cleanup order.

Recommended order:

1. Remove Open edX workloads first.
2. Remove the Redis Helm release.
3. Remove RDS-dependent Kubernetes Secrets and ConfigMaps.
4. Destroy Terraform-managed RDS and S3 only when they are no longer needed.
5. Be careful with S3 bucket contents. Terraform cannot delete non-empty buckets unless the bucket/resource is configured to allow that behavior.
6. Always run `terraform plan -destroy` before `terraform destroy`.

Do not run broad destroy commands casually. RDS and S3 can contain state that is expensive or impossible to recover if deleted incorrectly.

## Cost Notes

Phase 3 introduces or depends on billable resources.

- RDS is billable while running.
- NAT Gateway is already billable from Phase 1.
- The ingress-nginx LoadBalancer is billable from Phase 2.
- S3 is usually low cost at small scale, but storage, requests, and transfer can grow.
- In-cluster Redis uses EKS node CPU and memory.
- Destroy or stop the dev environment when work pauses for a long period.

Cost should be reviewed before applying Terraform for RDS and S3.

## Phase 3 Implementation Order

Recommended order:

1. Create `docs/phase-3-plan.md`.
2. Create a Terraform security group module or reusable security group patterns.
3. Create an RDS Terraform module.
4. Create an S3 Terraform module.
5. Run `terraform plan` and review the exact changes.
6. Apply Terraform only after review and explicit approval.
7. Install Redis with Helm after explicit approval.
8. Validate Redis connectivity from a debug pod.
9. Validate RDS DNS resolution and network reachability from a debug pod.
10. Document all outputs, verification commands, and rollback commands.

## Acceptance Criteria

Phase 3 is complete when:

- RDS exists in private subnets.
- RDS is not publicly accessible.
- S3 bucket exists with public access blocked and encryption enabled.
- Redis is running in-cluster and reachable only inside the cluster.
- A debug pod can connect to Redis.
- A debug pod can resolve and reach the RDS endpoint.
- Documentation includes verification and rollback commands.

## Non-Goals

Phase 3 does not include:

- Deploying Open edX.
- Configuring CloudFront.
- Deploying MongoDB.
- Deploying OpenSearch.
- Optimizing for full production high availability.
