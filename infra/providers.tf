terraform {
  cloud {
    organization = "Walletpan"
    workspaces {
      name = "Temp"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.47.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.30.0"
    }
  }
  required_version = ">=1.8.2"
}
provider "local" {
  # The local provider is needed for null_resource and local-exec
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "helm" {
  kubernetes {
    host                   = module.app-eks.endpoint
    cluster_ca_certificate = base64decode(module.app-eks.eks_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.app-eks.cluster_name
      ]
    }
  }
}

provider "time" {}

 