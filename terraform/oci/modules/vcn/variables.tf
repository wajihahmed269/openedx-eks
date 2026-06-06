variable "name" {
  description = "Name prefix for OCI networking resources."
  type        = string
}

variable "compartment_ocid" {
  description = "OCI compartment OCID where networking resources will be created."
  type        = string
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN."
  type        = string
}

variable "vcn_dns_label" {
  description = "DNS label for the VCN. OCI requires a short alphanumeric value."
  type        = string
  default     = "openedx"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public regional subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private regional subnets."
  type        = list(string)
}

variable "kubernetes_api_allowed_cidrs" {
  description = "CIDR blocks allowed to reach the public Kubernetes API endpoint on tcp/6443."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "freeform_tags" {
  description = "Freeform tags applied to OCI resources."
  type        = map(string)
  default     = {}
}
