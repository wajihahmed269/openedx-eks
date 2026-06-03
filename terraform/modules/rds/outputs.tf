output "planned_db_identifier" {
  description = "Planned RDS DB identifier. No RDS instance is created by this scaffold."
  value       = local.db_identifier
}

output "db_subnet_group_name" {
  description = "DB subnet group name for future RDS instances."
  value       = aws_db_subnet_group.this.name
}

output "db_subnet_group_id" {
  description = "DB subnet group ID."
  value       = aws_db_subnet_group.this.id
}

output "private_subnet_ids" {
  description = "Private subnets used by the DB subnet group."
  value       = var.private_subnet_ids
}

output "rds_security_group_id" {
  description = "Security group ID expected for future RDS instances."
  value       = var.rds_security_group_id
}

output "allowed_security_group_ids" {
  description = "Security groups expected to be allowed to reach future MySQL 3306."
  value       = var.allowed_security_group_ids
}
