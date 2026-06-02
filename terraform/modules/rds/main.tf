locals {
  db_identifier = var.name_prefix != null ? "${var.name_prefix}-${var.name}" : var.name
}

# Phase 3 RDS implementation placeholder.
# Future resources should include:
# - aws_db_subnet_group using private_subnet_ids only.
# - aws_db_instance with publicly_accessible = false.
# - Security group integration that allows MySQL 3306 only from EKS/app security groups.
# - Encrypted storage, backup retention, and dev-appropriate sizing.
# - Credentials sourced from AWS Secrets Manager or generated without committing secret values.
