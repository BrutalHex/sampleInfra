# "app-eks" module initializes the infrastructure
module "app-eks" {
  source                   = "./modules/eks"
  app_environment          = var.app_environment
  aws_region               = var.aws_region
  aws_profile              = var.aws_profile
  vpc_cidrblock            = var.vpc_cidrblock
  app_name                 = var.app_name
  aws_route53_domain       = var.aws_route53_domain
  aws_s3_bucket_backup_arn = var.aws_s3_bucket_backup_arn
}
# makes sure EKS is ready
resource "time_sleep" "wait_five_minutes" {
  create_duration = "10m"
  triggers = {
    always_run = timestamp() # Changes every time you run `terraform apply`
  }
}




# "kubernetes-base" module setups the k8s environment
module "kubernetes-base" {
  depends_on                                  = [module.app-eks, time_sleep.wait_five_minutes]
  source                                      = "./modules/kubernetes"
  aws_iam_role_csi_driver_arn                 = module.app-eks.aws_iam_role_csi_driver_arn
  csi_driver_service_account_name             = module.app-eks.csi_driver_service_account_name
  namespaces_nginx                            = "nginx-system"
  route53_service_account_name_external_dns   = module.app-eks.route53_service_account_name_external_dns
  service_account_name_cert_manager           = module.app-eks.service_account_name_cert_manager
  service_account_name_cert_manager_namespace = module.app-eks.service_account_name_cert_manager_namespace
  route53_id                                  = module.app-eks.route53_id
  aws_iam_role_route53_arn                    = module.app-eks.aws_iam_role_route53_arn
  domain                                      = module.app-eks.route53_domain
  aws_region                                  = var.aws_region
  app_name                                    = var.app_name
  cluster_autoscaler_role                     = module.app-eks.cluster_autoscaler_role
  aws_iam_role_load_balancer_arn              = module.app-eks.aws_iam_role_load_balancer_arn
  load_balancer_service_account               = module.app-eks.load_balancer_service_account
  cert_email                                  = var.cert_email
}



# "kubernetes-e2e" module setups the e2e isolated environment using k8s namespaces
module "kubernetes-e2e" {
  depends_on                     = [module.app-eks, module.kubernetes-base]
  source                         = "./modules/kubernetes-e2e"
  domain                         = module.app-eks.route53_domain
  aws_region                     = var.aws_region
  app_name                       = var.app_name
  backup_service_account_name    = module.app-eks.service_account_name_backup_bucket
  aws_iam_role_backup_bucket_arn = module.app-eks.aws_iam_role_backup_bucket_arn
  aws_s3_bucket_backup_arn       = var.aws_s3_bucket_backup_arn
  app_image                      = var.app_image
}
