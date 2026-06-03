variable "name" {
  description = "Bucket purpose suffix, such as openedx-assets."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used when bucket_name is not provided. S3 bucket names must be globally unique."
  type        = string
}

variable "bucket_name" {
  description = "Optional explicit globally unique bucket name."
  type        = string
  default     = null
}

variable "purpose" {
  description = "Human-readable purpose for the S3 bucket."
  type        = string
  default     = "Open edX media/static/uploads"
}

variable "enable_versioning" {
  description = "Whether to enable S3 bucket versioning."
  type        = bool
  default     = false
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm for default bucket encryption."
  type        = string
  default     = "AES256"
}

variable "tags" {
  description = "Tags for S3 resources."
  type        = map(string)
  default     = {}
}
