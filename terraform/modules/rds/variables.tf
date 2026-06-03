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
  description = "Private subnet IDs for the DB subnet group. RDS must not use public subnets."
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for RDS networking and security group associations."
  type        = string
}

variable "allowed_security_group_ids" {
  description = "Security group IDs that may connect to MySQL 3306, such as EKS worker or app security groups."
  type        = list(string)
  default     = []
}

variable "rds_security_group_id" {
  description = "Security group ID that RDS instances should attach to."
  type        = string
}

variable "engine" {
  description = "Database engine planned for Open edX."
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "MySQL engine version. Null lets AWS select the provider default for the engine family."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "Dev-sized RDS instance class for cost control."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage_gb" {
  description = "Allocated storage in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage_gb" {
  description = "Autoscaling storage upper bound in GiB. Set to 0 to disable storage autoscaling."
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "RDS storage type."
  type        = string
  default     = "gp3"
}

variable "database_name" {
  description = "Initial database name for Open edX."
  type        = string
  default     = "openedx"
}

variable "master_username" {
  description = "RDS master username. Password is generated and stored in Secrets Manager."
  type        = string
  default     = "openedx"
}

variable "master_password_length" {
  description = "Length of generated RDS master password."
  type        = number
  default     = 32
}

variable "port" {
  description = "MySQL port."
  type        = number
  default     = 3306
}

variable "backup_retention_period" {
  description = "Backup retention period in days. Enabled for dev with a non-zero value."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Deletion protection setting. False for dev, usually true for production."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on destroy. True for dev convenience; revisit for production."
  type        = bool
  default     = true
}

variable "secret_name" {
  description = "Optional Secrets Manager secret name for DB credentials."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags for RDS resources."
  type        = map(string)
  default     = {}
}
