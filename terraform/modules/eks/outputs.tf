output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID. Managed node groups use this for cluster/node communication when no dedicated node SG is exposed."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}
