output "bucket_name" {
  description = "S3 bucket name."
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "S3 bucket ARN."
  value       = aws_s3_bucket.this.arn
}

output "bucket_region" {
  description = "AWS region where the bucket is hosted."
  value       = aws_s3_bucket.this.region
}

output "versioning_enabled" {
  description = "Whether S3 bucket versioning is enabled."
  value       = var.enable_versioning
}

output "sse_algorithm" {
  description = "Server-side encryption algorithm configured for the bucket."
  value       = var.sse_algorithm
}
