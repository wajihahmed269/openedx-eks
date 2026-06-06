output "vcn_id" {
  description = "OCID of the OCI VCN."
  value       = module.vcn.vcn_id
}

output "vcn_cidr" {
  description = "CIDR block of the OCI VCN."
  value       = module.vcn.vcn_cidr
}

output "public_subnet_ids" {
  description = "OCIDs of public regional subnets."
  value       = module.vcn.public_subnet_ids
}

output "private_subnet_ids" {
  description = "OCIDs of private regional subnets."
  value       = module.vcn.private_subnet_ids
}

output "internet_gateway_id" {
  description = "OCID of the Internet Gateway."
  value       = module.vcn.internet_gateway_id
}

output "nat_gateway_id" {
  description = "OCID of the NAT Gateway."
  value       = module.vcn.nat_gateway_id
}

output "oke_cluster_id" {
  description = "OCID of the OKE cluster."
  value       = module.oke.cluster_id
}

output "oke_cluster_name" {
  description = "Name of the OKE cluster."
  value       = module.oke.cluster_name
}

output "oke_cluster_type" {
  description = "OKE cluster type."
  value       = module.oke.cluster_type
}

output "oke_kubernetes_version" {
  description = "Kubernetes version configured for OKE."
  value       = module.oke.kubernetes_version
}

output "oke_node_pool_id" {
  description = "OCID of the OKE node pool."
  value       = module.oke.node_pool_id
}

output "oke_node_shape" {
  description = "Configured OKE worker node shape."
  value       = module.oke.node_shape
}

output "oke_node_pool_size" {
  description = "Configured OKE worker node count."
  value       = module.oke.node_pool_size
}

output "oke_kubeconfig_command" {
  description = "OCI CLI command to write kubeconfig after the cluster exists."
  value       = module.oke.kubeconfig_command
}
