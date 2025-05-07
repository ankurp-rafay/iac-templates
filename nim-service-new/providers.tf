provider "kubernetes" {
  config_path = "kubeconfig.json"
}

provider "kubectl" {
  config_path = "kubeconfig.json"
}

provider "aws" {
  region = "us-west-2"
}

terraform {
  required_providers {
   kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}
