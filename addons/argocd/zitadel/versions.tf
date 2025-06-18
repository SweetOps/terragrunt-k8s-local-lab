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
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5"
    }
  }
}
