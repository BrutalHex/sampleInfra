locals {
  common_tags = {
    env = "${var.app_name}_${var.app_environment}_eks"
  }
}