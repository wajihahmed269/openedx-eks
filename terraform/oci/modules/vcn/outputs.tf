output "vcn_id" {
  description = "OCID of the VCN."
  value       = oci_core_vcn.this.id
}

output "vcn_cidr" {
  description = "CIDR block of the VCN."
  value       = oci_core_vcn.this.cidr_block
}

output "public_subnet_ids" {
  description = "OCIDs of public regional subnets."
  value       = oci_core_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "OCIDs of private regional subnets."
  value       = oci_core_subnet.private[*].id
}

output "public_route_table_id" {
  description = "OCID of the public route table."
  value       = oci_core_route_table.public.id
}

output "private_route_table_id" {
  description = "OCID of the private route table."
  value       = oci_core_route_table.private.id
}

output "public_security_list_id" {
  description = "OCID of the public subnet security list."
  value       = oci_core_security_list.public.id
}

output "private_security_list_id" {
  description = "OCID of the private subnet security list."
  value       = oci_core_security_list.private.id
}

output "internet_gateway_id" {
  description = "OCID of the Internet Gateway."
  value       = oci_core_internet_gateway.this.id
}

output "nat_gateway_id" {
  description = "OCID of the NAT Gateway."
  value       = oci_core_nat_gateway.this.id
}
