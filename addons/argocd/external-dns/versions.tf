terraform {
  required_version = ">= 1.10.0"

  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "~> 7"
    }
    utils = {
      source  = "cloudposse/utils"
      version = "~> 1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2"
    }
  }
}
