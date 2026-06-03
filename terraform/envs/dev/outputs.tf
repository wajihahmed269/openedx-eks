output "project_name" {
  value = var.project_name
}

output "environment" {
  value = var.environment
}

output "aws_region" {
  value = var.aws_region
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "rds_security_group_id" {
  value = module.rds_security_group.security_group_id
}

output "rds_db_subnet_group_name" {
  value = module.rds.db_subnet_group_name
}

output "rds_db_endpoint" {
  value = module.rds.db_endpoint
}

output "rds_db_port" {
  value = module.rds.db_port
}

output "rds_database_name" {
  value = module.rds.database_name
}

output "rds_credentials_secret_arn" {
  value = module.rds.credentials_secret_arn
}

output "s3_openedx_assets_bucket_name" {
  value = module.s3_openedx_assets.bucket_name
}

output "s3_openedx_assets_bucket_arn" {
  value = module.s3_openedx_assets.bucket_arn
}

output "s3_openedx_assets_bucket_region" {
  value = module.s3_openedx_assets.bucket_region
}

output "s3_openedx_assets_versioning_enabled" {
  value = module.s3_openedx_assets.versioning_enabled
}
