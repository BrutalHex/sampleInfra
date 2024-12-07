variable "namespaces_nginx" {
  description = "The Kubernetes namespace where the NGINX ingress controller will be deployed."
  default     = "nginx-system"
}

variable "csi_driver_service_account_name" {
  description = "The name of the Kubernetes service account used by the CSI (Container Storage Interface) driver."
}

variable "aws_iam_role_csi_driver_arn" {
  description = "The ARN of the AWS IAM role associated with the CSI driver for permissions to manage EBS volumes."
}

variable "aws_region" {
  description = "The AWS region where the resources are being deployed (e.g., us-east-1, eu-west-1)."
}

variable "app_name" {
  description = "The name of the application being deployed, used for labeling and resource identification."
}

variable "route53_id" {
  description = "The ID of the AWS Route 53 hosted zone where DNS records will be managed."
}

variable "route53_service_account_name_external_dns" {
  description = "The name of the Kubernetes service account used by ExternalDNS to manage Route 53 DNS records."
}

variable "service_account_name_cert_manager" {
  description = "The name of the Kubernetes service account used by the Cert-Manager component."
}

variable "service_account_name_cert_manager_namespace" {
  description = "The Kubernetes namespace where the Cert-Manager service account is located."
}

variable "aws_iam_role_route53_arn" {
  description = "The ARN of the AWS IAM role with permissions to manage Route 53 records."
}

variable "domain" {
  description = "The domain name for which DNS and TLS certificates will be managed."
}

variable "cert_email" {
  description = "The email address used for TLS certificate registration and notifications."
}

variable "cluster_autoscaler_role" {
  description = "The name or ARN of the IAM role used by the Kubernetes Cluster Autoscaler."
}

variable "aws_iam_role_load_balancer_arn" {
  description = "The ARN of the AWS IAM role with permissions to manage Load Balancer resources."
}

variable "load_balancer_service_account" {
  description = "The name of the Kubernetes service account used for managing nginx Load Balancer"
}



