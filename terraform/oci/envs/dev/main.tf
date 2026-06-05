locals {
  name = "${var.project_name}-${var.environment}"

  common_tags = merge(var.common_tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

module "vcn" {
  source = "../../modules/vcn"

  name                 = local.name
  compartment_ocid     = var.compartment_ocid
  vcn_cidr             = var.vcn_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  freeform_tags        = local.common_tags
}
