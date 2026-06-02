locals {
  bucket_name = var.bucket_name != null ? var.bucket_name : lower("${var.name_prefix}-${var.name}")
}

# Phase 3 S3 implementation placeholder.
# Future resources should include:
# - aws_s3_bucket using a deterministic environment-specific name.
# - aws_s3_bucket_public_access_block with all public access blocked by default.
# - aws_s3_bucket_server_side_encryption_configuration.
# - Optional aws_s3_bucket_versioning for long-lived environments.
# - IAM/IRSA access for Open edX workloads instead of static AWS keys.
