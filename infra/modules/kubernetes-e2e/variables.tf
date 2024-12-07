



variable "aws_region" {
  description = "The AWS region where the resources are being deployed (e.g., us-east-1, eu-west-1)."
}

variable "app_name" {
  description = "The name of the application being deployed, used for labeling and resource identification."
}

variable "domain" {
  description = "The domain name for which DNS and TLS certificates will be managed."
}

variable "aws_s3_bucket_backup_arn" {
  description = "the the url of backup bucket thatholds the snapshot of DB"
  type        = string
}

variable "aws_s3_bucket_backup_file" {
  description = "the the url of backup bucket thatholds the snapshot of DB"
  type        = string
  default     = "data.sql"
}

variable "backup_service_account_name" {
  description = "the name of SA account that has access to s3bucket that has backups"
  type        = string
}

variable "aws_iam_role_backup_bucket_arn" {
  description = "the name of IAM role that has access to s3bucket that serve as backup bucket"
  type        = string
}

variable "app_image" {
  description = "the image of the application to be tested"
  type        = string
}