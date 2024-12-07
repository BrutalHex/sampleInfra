
output "endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}
output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.eks.url
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = aws_eks_cluster.eks.name
}
output "cluster_id" {
  description = "Kubernetes Cluster id"
  value       = aws_eks_cluster.eks.id
}
output "cluster_autoscaler_role" {
  description = "Kubernetes Cluster role for auto discovery"
  value       = aws_iam_role.cluster_autoscaler.arn
}
output "eks_certificate_authority_data" {
  description = "Kubernetes Cluster certificate"
  value       = aws_eks_cluster.eks.certificate_authority.0.data
}

output "aws_eks_cluster_auth_token" {
  value = data.aws_eks_cluster_auth.eks.token
}

output "csi_driver_service_account_name" {
  value = local.service-account-name
}
output "aws_iam_role_csi_driver_arn" {
  value = aws_iam_role.csi-driver.arn
}

output "route53_service_account_name_external_dns" {
  value = local.service_account_name_external_dns
}

output "service_account_name_cert_manager" {
  value = local.service_account_name_cert_manager
}
output "service_account_name_cert_manager_namespace" {
  value = local.service_account_name_cert_manager_namespace
}
output "aws_iam_role_route53_arn" {
  value = aws_iam_role.route53.arn
}
output "route53_domain" {
  value = aws_route53_zone.eks.name
}
output "route53_id" {
  value = aws_route53_zone.eks.id
}
output "aws_iam_role_load_balancer_arn" {
  value = aws_iam_role.load-balancer.arn
}
output "load_balancer_service_account" {
  value = local.load-balancer-service-account
}

output "service_account_name_backup_bucket" {
  value = local.service_account_name_backup_bucket
}
output "aws_iam_role_backup_bucket_arn" {
  value = aws_iam_role.s3-backup.arn
}