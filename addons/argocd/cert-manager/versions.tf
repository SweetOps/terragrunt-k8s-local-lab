terraform {
  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "~> 7"
    }
    utils = {
      source  = "cloudposse/utils"
      version = "~> 1"
    }
  }
}
