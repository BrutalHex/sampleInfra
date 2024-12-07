variable "app_environment" {
  default = "dev"
}
variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_profile" {
  default = "default"
}
variable "vpc_cidrblock" {
  description = "the cidr block of vpc"
  type        = string
}
variable "app_name" {
  type = string
}
variable "az_number" {
  default = {
    a = 1,
    b = 2
  }
}

variable "aws_route53_domain" {
  description = "the domain of hosted zone"
  type        = string
}

variable "aws_s3_bucket_backup_arn" {
  description = "the the url of backup bucket thatholds the snapshot of DB"
  type        = string
}