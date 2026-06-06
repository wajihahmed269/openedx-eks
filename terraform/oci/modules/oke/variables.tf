variable "name" {
  description = "Name prefix for OKE resources."
  type        = string
}

variable "region" {
  description = "OCI region for kubeconfig instructions."
  type        = string
}

variable "compartment_ocid" {
  description = "OCI compartment OCID where OKE resources will be created."
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN where OKE will be created."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the OKE cluster and node pool."
  type        = string
}

variable "cluster_type" {
  description = "OKE cluster type. BASIC_CLUSTER avoids the enhanced cluster control plane fee."
  type        = string
  default     = "BASIC_CLUSTER"
}

variable "public_subnet_ids" {
  description = "Public subnet OCIDs used for the Kubernetes API endpoint and future service load balancers."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet OCIDs used for worker nodes."
  type        = list(string)
}

variable "is_public_ip_enabled" {
  description = "Whether the Kubernetes API endpoint receives a public IP."
  type        = bool
  default     = true
}

variable "pods_cidr" {
  description = "Overlay pod CIDR used by OKE. Must not overlap the VCN CIDR."
  type        = string
  default     = "10.244.0.0/16"
}

variable "services_cidr" {
  description = "Kubernetes service CIDR used by OKE. Must not overlap the VCN CIDR."
  type        = string
  default     = "10.96.0.0/16"
}

variable "node_pool_size" {
  description = "Number of worker nodes in the initial node pool."
  type        = number
  default     = 1
}

variable "node_shape" {
  description = "OCI Compute shape for OKE worker nodes. Defaults to x86 E4 Flex for Open edX compatibility."
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "node_ocpus" {
  description = "OCPUs per worker node for flexible shapes. On x86 shapes, 1 OCPU maps to 2 vCPUs."
  type        = number
  default     = 2
}

variable "node_memory_in_gbs" {
  description = "Memory in GB per worker node for flexible shapes."
  type        = number
  default     = 24
}

variable "node_boot_volume_size_in_gbs" {
  description = "Optional boot volume size in GB when node_image_id is provided. OCI OKE node images require at least 50 GB."
  type        = number
  default     = 50
}

variable "node_image_id" {
  description = "Optional OKE-compatible worker node image OCID. Leave null to let OKE use its default image for the Kubernetes version."
  type        = string
  default     = null
}

variable "freeform_tags" {
  description = "Freeform tags applied to OKE resources."
  type        = map(string)
  default     = {}
}
