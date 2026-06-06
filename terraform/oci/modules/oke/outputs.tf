output "cluster_id" {
  description = "OCID of the OKE cluster."
  value       = oci_containerengine_cluster.this.id
}

output "cluster_name" {
  description = "Name of the OKE cluster."
  value       = oci_containerengine_cluster.this.name
}

output "cluster_type" {
  description = "OKE cluster type."
  value       = oci_containerengine_cluster.this.type
}

output "kubernetes_version" {
  description = "Kubernetes version configured for the cluster."
  value       = oci_containerengine_cluster.this.kubernetes_version
}

output "node_pool_id" {
  description = "OCID of the OKE node pool."
  value       = oci_containerengine_node_pool.this.id
}

output "node_pool_name" {
  description = "Name of the OKE node pool."
  value       = oci_containerengine_node_pool.this.name
}

output "node_shape" {
  description = "Worker node shape."
  value       = oci_containerengine_node_pool.this.node_shape
}

output "node_pool_size" {
  description = "Configured worker node count."
  value       = var.node_pool_size
}

output "kubeconfig_command" {
  description = "OCI CLI command to write kubeconfig after the cluster exists."
  value       = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.this.id} --file $HOME/.kube/config --region ${var.region} --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT"
}
