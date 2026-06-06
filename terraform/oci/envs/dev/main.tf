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

  name                         = local.name
  compartment_ocid             = var.compartment_ocid
  vcn_cidr                     = var.vcn_cidr
  public_subnet_cidrs          = var.public_subnet_cidrs
  private_subnet_cidrs         = var.private_subnet_cidrs
  kubernetes_api_allowed_cidrs = var.kubernetes_api_allowed_cidrs
  freeform_tags                = local.common_tags
}

module "oke" {
  source = "../../modules/oke"

  name                         = local.name
  region                       = var.region
  compartment_ocid             = var.compartment_ocid
  vcn_id                       = module.vcn.vcn_id
  public_subnet_ids            = module.vcn.public_subnet_ids
  private_subnet_ids           = module.vcn.private_subnet_ids
  kubernetes_version           = var.kubernetes_version
  cluster_type                 = var.oke_cluster_type
  is_public_ip_enabled         = var.oke_api_endpoint_public
  pods_cidr                    = var.oke_pods_cidr
  services_cidr                = var.oke_services_cidr
  node_pool_size               = var.oke_node_pool_size
  node_shape                   = var.oke_node_shape
  node_ocpus                   = var.oke_node_ocpus
  node_memory_in_gbs           = var.oke_node_memory_in_gbs
  node_boot_volume_size_in_gbs = var.oke_node_boot_volume_size_in_gbs
  node_image_id                = var.oke_node_image_id
  freeform_tags                = local.common_tags
}
