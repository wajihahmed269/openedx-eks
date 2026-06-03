variable "name" {
  description = "RDS identifier suffix, such as mysql."
  type        = string
}

variable "name_prefix" {
  description = "Optional prefix for production-style names, usually the environment resource prefix."
  type        = string
  default     = null
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the future DB subnet group. RDS must not use public subnets."
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for future RDS networking and security group associations."
  type        = string
}

variable "allowed_security_group_ids" {
  description = "Security group IDs that may connect to MySQL 3306, such as EKS worker or app security groups."
  type        = list(string)
  default     = []
}

variable "rds_security_group_id" {
  description = "Security group ID that future RDS instances should attach to. This scaffold does not create an RDS instance yet."
  type        = string
}

variable "engine" {
  description = "Database engine planned for Open edX."
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "Future MySQL engine version. Set during implementation after compatibility review."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "Future dev-sized RDS instance class for cost control."
  type        = string
  default     = null
}

variable "allocated_storage_gb" {
  description = "Future allocated storage in GiB."
  type        = number
  default     = null
}

variable "backup_retention_period" {
  description = "Future backup retention period in days."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Future deletion protection setting. Usually false for dev and true for production."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for future RDS resources."
  type        = map(string)
  default     = {}
}
