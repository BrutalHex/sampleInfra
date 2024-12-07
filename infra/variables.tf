variable "app_environment" {
  description = "the name of the environment , eg: dev,test,..."
  type        = string
}
variable "aws_region" {
  description = "the aws region that the infrastructure will be deployed"
  type        = string
}
variable "aws_access_key" {
  description = "the aws access key"
  type        = string
}
variable "aws_secret_key" {
  description = "the aws secret key"
  type        = string
}

variable "aws_profile" {
  description = "the name of default aws profile"
  default     = "default"
}

variable "vpc_cidrblock" {
  description = "the cidr block of vpc"
  type        = string
  default     = "172.32.0.0/16"
}

variable "app_name" {
  description = "the name of the application group"
  type        = string
  default     = "myapp"
}


variable "aws_route53_domain" {
  description = "the domain of hosted zone"
  type        = string
  default     = "example.com"
}

variable "cert_email" {
  description = "the email to beused for letsencrypt registeration"
  type        = string
  default     = "hi@example.com"
}

variable "aws_s3_bucket_backup_arn" {
  description = "the the url of backup bucket thatholds the snapshot of DB"
  type        = string
}
variable "app_image" {
  description = "the image of the application to be tested"
  type        = string
}

