output "planned_db_identifier" {
  description = "Planned RDS DB identifier. No RDS resource is created by this scaffold."
  value       = local.db_identifier
}

output "private_subnet_ids" {
  description = "Private subnets expected for the future DB subnet group."
  value       = var.private_subnet_ids
}

output "allowed_security_group_ids" {
  description = "Security groups expected to be allowed to reach future MySQL 3306."
  value       = var.allowed_security_group_ids
}
