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
