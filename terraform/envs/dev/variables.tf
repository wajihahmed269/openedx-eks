variable "aws_region" {
  description = "AWS region for the dev environment"
  type        = string
}

variable "project_name" {
  description = "Project name used for tagging AWS resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
}

variable "s3_enable_versioning" {
  description = "Whether to enable versioning for the Open edX assets S3 bucket"
  type        = bool
  default     = false
}
