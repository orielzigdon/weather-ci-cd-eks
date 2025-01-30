output "eks_cluster_id" {
  description = "The EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "eks_cluster_endpoint" {
  description = "The EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_security_group_id" {
  description = "The security group ID attached to the EKS cluster"
  value       = aws_security_group.eks.id
}
