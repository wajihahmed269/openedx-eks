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

variable "kubernetes_api_allowed_cidrs" {
  description = "CIDR blocks allowed to reach the public OKE Kubernetes API endpoint on tcp/6443. Narrow this before apply when possible."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "kubernetes_version" {
  description = "Kubernetes version for the OKE cluster and node pool."
  type        = string
  default     = "v1.35.2"
}

variable "oke_cluster_type" {
  description = "OKE cluster type. BASIC_CLUSTER avoids the enhanced cluster control plane fee."
  type        = string
  default     = "BASIC_CLUSTER"
}

variable "oke_api_endpoint_public" {
  description = "Whether the Kubernetes API endpoint receives a public IP."
  type        = bool
  default     = true
}

variable "oke_pods_cidr" {
  description = "Overlay pod CIDR used by OKE. Must not overlap the VCN CIDR."
  type        = string
  default     = "10.244.0.0/16"
}

variable "oke_services_cidr" {
  description = "Kubernetes service CIDR used by OKE. Must not overlap the VCN CIDR."
  type        = string
  default     = "10.96.0.0/16"
}

variable "oke_node_pool_size" {
  description = "Number of worker nodes in the initial OKE node pool."
  type        = number
  default     = 1
}

variable "oke_node_shape" {
  description = "OCI Compute shape for OKE worker nodes. Defaults to x86 E4 Flex for Open edX compatibility."
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "oke_node_ocpus" {
  description = "OCPUs per worker node for flexible shapes. On x86 shapes, 1 OCPU maps to 2 vCPUs."
  type        = number
  default     = 2
}

variable "oke_node_memory_in_gbs" {
  description = "Memory in GB per worker node for flexible shapes."
  type        = number
  default     = 24
}

variable "oke_node_boot_volume_size_in_gbs" {
  description = "Boot volume size in GB when an explicit worker node image is provided."
  type        = number
  default     = 50
}

variable "oke_node_image_id" {
  description = "Optional OKE-compatible worker node image OCID. Set this for reproducible node image selection."
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common freeform tags to apply to OCI resources."
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "openedx-oci"
  }
}
