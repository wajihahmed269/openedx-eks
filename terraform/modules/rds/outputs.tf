output "db_identifier" {
  description = "RDS DB identifier."
  value       = aws_db_instance.this.identifier
}

output "db_endpoint" {
  description = "RDS endpoint hostname."
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "RDS MySQL port."
  value       = aws_db_instance.this.port
}

output "database_name" {
  description = "Initial database name."
  value       = aws_db_instance.this.db_name
}

output "master_username" {
  description = "RDS master username. Password is not output."
  value       = var.master_username
}

output "credentials_secret_arn" {
  description = "Secrets Manager ARN containing generated DB credentials."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_subnet_group_name" {
  description = "DB subnet group name for RDS instances."
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
  description = "Security group ID attached to the RDS instance."
  value       = var.rds_security_group_id
}

output "allowed_security_group_ids" {
  description = "Security groups expected to be allowed to reach MySQL 3306."
  value       = var.allowed_security_group_ids
}
