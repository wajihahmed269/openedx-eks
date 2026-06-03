# Phase 3A - RDS Networking And Security Foundation

## Goal

Phase 3A prepares the private networking and security group foundation required before creating an RDS MySQL instance for Open edX.

This phase does not create an RDS database instance. It only prepares:

- A reusable security group pattern.
- A dedicated RDS MySQL security group.
- A DB subnet group using private subnets only.

## RDS Private Subnet Design

RDS must live in private subnets only. The DB subnet group is built from `module.vpc.private_subnet_ids`, so future RDS instances can be placed away from public internet routing.

Future RDS instances must use:

```hcl
publicly_accessible = false
```

The RDS endpoint should be reachable only from approved application infrastructure inside the VPC.

## Security Group Flow

The current EKS module does not expose a dedicated managed node group security group. The safest available source is the EKS cluster security group exposed by `module.eks.cluster_security_group_id`.

Current planned flow:

```text
Open edX pod on EKS node
  -> EKS cluster security group
  -> RDS security group inbound tcp/3306
  -> Future RDS MySQL private endpoint
```

The RDS security group allows MySQL `3306` only from the EKS cluster security group. It does not allow access from public CIDRs.

If a dedicated application security group or node security group is introduced later, the RDS ingress source should be narrowed to that group.

## Why The Database Must Not Be Public

Databases hold application state, user data, operational metadata, and credentials-derived data. Public database endpoints increase attack surface and make access depend too heavily on credential secrecy alone.

The safer design is:

- Private subnet placement.
- `publicly_accessible = false`.
- Security group allowlists from known application infrastructure.
- No `0.0.0.0/0` database ingress.

## What Is Not Created Yet

Phase 3A does not create:

- `aws_db_instance`
- Database users or passwords
- AWS Secrets Manager secrets
- Open edX Kubernetes Secrets
- Redis
- Open edX workloads

## Validation Commands

Format and validate Terraform:

```bash
terraform fmt -recursive
terraform validate
```

Review the exact infrastructure changes before applying later:

```bash
terraform plan
```

Expected plan scope for Phase 3A:

- Create one RDS MySQL security group.
- Create one MySQL ingress rule from the EKS cluster security group.
- Create one DB subnet group using private subnets.
- Do not create an RDS instance.

## Rollback Notes

No resources are created until `terraform apply` is explicitly approved and run.

If these resources are applied later, rollback should happen only after confirming no RDS instance depends on the subnet group or security group.

Future cleanup order:

1. Remove Open edX workloads and database-dependent configs.
2. Remove any RDS instance that depends on the subnet group and security group.
3. Remove the DB subnet group.
4. Remove the RDS security group.

Always run:

```bash
terraform plan -destroy
```

before any destroy operation.
