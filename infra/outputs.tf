
output "region" {
  value = var.aws_region
}
output "endpoint" {
  value = module.app-eks.endpoint
}
output "cluster_name" {
  value = module.app-eks.cluster_name
}

output "cluster_autoscaler_role" {
  value = module.app-eks.cluster_autoscaler_role
}

output "eks_certificate_authority_data" {
  value = module.app-eks.eks_certificate_authority_data
}

output "app_domain" {
  value = module.kubernetes-e2e.app_domain
}

output "timer_complete" {
  value      = "5-minute timer is complete!"
  depends_on = [time_sleep.wait_five_minutes]
}