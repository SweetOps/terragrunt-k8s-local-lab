terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2"
    }
  }
}
