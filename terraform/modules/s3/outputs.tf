output "planned_bucket_name" {
  description = "Planned S3 bucket name. No bucket is created by this scaffold."
  value       = local.bucket_name
}

output "enable_versioning" {
  description = "Future versioning setting."
  value       = var.enable_versioning
}

output "sse_algorithm" {
  description = "Future server-side encryption algorithm."
  value       = var.sse_algorithm
}
