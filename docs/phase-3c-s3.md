# Phase 3C - S3 Bucket for Open edX Assets

## Purpose

Phase 3C provisions a private Amazon S3 bucket for Open edX media, static files, and uploads in the dev environment. The bucket is intended to hold application-managed assets only; it does not expose public website hosting, CloudFront, IAM users, access keys, or bucket policies.

## Private Bucket Design

The dev environment wires `terraform/modules/s3` as `module.s3_openedx_assets`. The bucket name is deterministic and includes the project, environment, AWS account ID, and region:

```text
<project>-<environment>-openedx-assets-<account-id>-<region>
```

For the current dev variables this resolves to a name shaped like:

```text
openedx-eks-dev-openedx-assets-<account-id>-us-east-1
```

The bucket remains private by default. No public bucket policy is created, and `force_destroy` is disabled so Terraform will not delete a non-empty bucket automatically.

## Encryption

Default server-side encryption is enabled with Amazon S3 managed keys (`AES256`, SSE-S3). This avoids creating or managing a customer KMS key during this phase while still ensuring objects are encrypted at rest by default.

## Public Access Block

The module enables all S3 public access block controls:

```text
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true
```

This keeps the bucket private even if an ACL or policy is accidentally introduced later.

## Versioning

Versioning is configurable through `s3_enable_versioning` in `terraform/envs/dev`. It defaults to `false` for dev to limit storage growth. Production or long-lived environments should consider enabling versioning to protect user uploads from accidental overwrite or deletion.

## Future IRSA Access

Open edX workloads should access this bucket through IAM Roles for Service Accounts (IRSA) on EKS. Do not create static AWS access keys for Open edX pods. A later phase should add:

- An IAM policy scoped to the specific bucket and required object prefixes.
- An IAM role trusted by the EKS OIDC provider.
- Kubernetes service account annotations for the Open edX workloads that need S3 access.

## Validation Commands

Run these from `terraform/envs/dev`:

```bash
terraform fmt -recursive
terraform validate
terraform plan
```

After apply is explicitly approved and completed in a later step, useful read-only checks are:

```bash
terraform output s3_openedx_assets_bucket_name
aws s3api get-public-access-block --bucket "$(terraform output -raw s3_openedx_assets_bucket_name)"
aws s3api get-bucket-encryption --bucket "$(terraform output -raw s3_openedx_assets_bucket_name)"
aws s3api get-bucket-versioning --bucket "$(terraform output -raw s3_openedx_assets_bucket_name)"
```

## Rollback Notes

Do not delete AWS resources as part of rollback without explicit approval. If Phase 3C needs to be rolled back before apply, revert the Terraform and documentation changes. If it has already been applied, first confirm whether the bucket contains any Open edX data, back up anything required, and then plan a controlled Terraform change. Because `force_destroy = false`, Terraform will not remove a non-empty bucket automatically.

## Cost Notes

S3 costs are mainly driven by stored object volume, request volume, data transfer, and versioned object retention. With versioning disabled in dev, cost remains lower because overwritten or deleted objects do not accumulate historical versions. Enabling versioning later can increase storage cost and should be paired with lifecycle management once retention requirements are known.
