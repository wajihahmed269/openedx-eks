variable "region" {
  description = "OCI region for the dev environment."
  type        = string
  default     = "me-jeddah-1"
}

variable "compartment_ocid" {
  description = "OCI compartment OCID where dev resources will be created."
  type        = string
}

variable "oci_auth" {
  description = "OCI Terraform provider authentication mode. Use SecurityToken for OCI CLI session auth or APIKey for config-file API key auth."
  type        = string
  default     = "SecurityToken"
}

variable "oci_config_file_profile" {
  description = "OCI CLI config profile used by the Terraform provider."
  type        = string
  default     = "DEFAULT"
}

variable "project_name" {
  description = "Project name used for naming OCI resources."
  type        = string
  default     = "openedx-oci"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "vcn_cidr" {
  description = "CIDR block planned for the OCI VCN."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks planned for public regional subnets."
  type        = list(string)
  default     = ["10.20.10.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks planned for private regional subnets."
  type        = list(string)
  default     = ["10.20.20.0/24"]
}

variable "common_tags" {
  description = "Common freeform tags to apply to OCI resources in later phases."
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "openedx-oci"
  }
}
