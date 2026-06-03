# Phase 3B - RDS MySQL Implementation

## Goal

Phase 3B implements a private RDS MySQL database for Open edX using Terraform.

This phase still does not deploy Open edX. It creates the database dependency that Open edX can use later.

## Design

RDS uses the Phase 3A networking foundation:

```text
Open edX pods on EKS
  -> EKS cluster security group
  -> RDS security group tcp/3306
  -> RDS MySQL endpoint in private subnets
```

The RDS instance is private-only:

```hcl
publicly_accessible = false
storage_encrypted   = true
```

The instance uses the existing DB subnet group built from private subnets and the existing RDS security group.

## Dev Sizing And Safety

The dev defaults are intentionally small for cost control:

- `instance_class = "db.t4g.micro"`
- `allocated_storage_gb = 20`
- `max_allocated_storage_gb = 100`
- `backup_retention_period = 1`
- `deletion_protection = false`

Deletion protection is disabled only because this is a dev assessment environment. Production should enable deletion protection and revisit snapshot settings.

The initial apply failed with `FreeTierRestrictionError` because the AWS account's free-tier RDS path rejected a 7-day backup retention period. Dev now uses the lowest non-zero backup retention value, `1`, to keep backups enabled while satisfying the current account limitation. Production should increase retention after leaving free-tier constraints.

## Credentials

The database password is generated with Terraform `random_password` and stored in AWS Secrets Manager.

Secret values are not committed to Git and are not exposed as Terraform outputs.

Safe outputs include:

- DB identifier
- DB endpoint
- DB port
- Database name
- Master username
- Secrets Manager secret ARN

## Validation Commands

```bash
terraform fmt -recursive
terraform validate
terraform plan
```

Expected plan scope:

- RDS security group and MySQL ingress rule from Phase 3A, if not applied yet.
- DB subnet group from Phase 3A, if not applied yet.
- RDS MySQL instance.
- Generated password.
- Secrets Manager secret and secret version.

The plan must not include public database access.

## Post-Apply Verification Commands

Run only after an approved `terraform apply`:

```bash
terraform output rds_db_endpoint
terraform output rds_db_port
terraform output rds_credentials_secret_arn
```

Network validation should happen from inside the cluster using a temporary debug pod after approval.

## Rollback Notes

Do not destroy the database until Open edX workloads and DB-dependent Kubernetes configuration are removed.

Safe future order:

1. Remove Open edX workloads.
2. Remove Open edX DB secrets/configs.
3. Confirm no app depends on RDS.
4. Run `terraform plan -destroy` and review it.
5. Destroy only after explicit approval.

Do not delete Secrets Manager secrets or RDS snapshots casually. They may be needed for recovery.
