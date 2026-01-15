terraform {
  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "~> 7"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3"
    }
    utils = {
      source  = "cloudposse/utils"
      version = "~> 1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
  }
}
