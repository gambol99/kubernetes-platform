
output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "The certificate authority of the EKS cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "argocd_spoke_role_arn" {
  description = "When provisioning a spoke, the is the IAM role the hub must assume"
  value       = module.eks.cross_account_role_arn
}
