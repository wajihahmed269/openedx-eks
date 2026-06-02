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

variable "enable_versioning" {
  description = "Future versioning flag. Consider enabling for production or long-lived environments."
  type        = bool
  default     = false
}

variable "sse_algorithm" {
  description = "Future server-side encryption algorithm."
  type        = string
  default     = "AES256"
}

variable "tags" {
  description = "Tags for future S3 resources."
  type        = map(string)
  default     = {}
}
