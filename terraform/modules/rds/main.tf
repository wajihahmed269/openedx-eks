locals {
  db_identifier        = var.name_prefix != null ? "${var.name_prefix}-${var.name}" : var.name
  db_subnet_group_name = "${local.db_identifier}-subnet-group"
}

resource "aws_db_subnet_group" "this" {
  name        = local.db_subnet_group_name
  description = "Private subnet group for ${local.db_identifier}"
  subnet_ids  = var.private_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = local.db_subnet_group_name
    }
  )
}

# Phase 3A creates only RDS networking prerequisites.
# Future RDS instance implementation should use:
# - aws_db_instance with publicly_accessible = false.
# - vpc_security_group_ids = [var.rds_security_group_id].
# - db_subnet_group_name = aws_db_subnet_group.this.name.
# - Encrypted storage, backup retention, and dev-appropriate sizing.
# - Credentials sourced from AWS Secrets Manager or generated without committing secret values.
