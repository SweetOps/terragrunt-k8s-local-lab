variable "name" {
  description = "Name of the container"
  type        = string
  default     = "registry"
}

variable "image" {
  description = "Docker image to use for the container"
  type        = string
  default     = "ghcr.io/project-zot/zot:v2.1.12"
}

variable "command" {
  description = "Command to run in the container"
  type        = list(string)
  default     = ["serve", "/etc/zot/config.json"]
}

variable "entrypoint" {
  description = "Entrypoint for the container"
  type        = list(string)
  default     = ["/usr/local/bin/zot-linux-arm64"]
}

variable "env" {
  description = "Environment variables to set in the container"
  type        = list(string)
  default     = []
}

variable "privileged" {
  description = "Run the container in privileged mode"
  type        = bool
  default     = false
}

variable "restart" {
  description = "Restart policy for the container"
  type        = string
  default     = "unless-stopped"
}

variable "networks_advanced" {
  description = "Advanced network settings for the container"
  type = object(
    {
      name         = string
      ipv4_address = optional(string)
      ipv6_address = optional(string)
    }
  )
  default = {
    name = "kind"
  }
}

variable "mounts" {
  description = "List of mounts for the container"
  type = list(
    object(
      {
        source    = string
        target    = string
        read_only = optional(bool, false)
        type      = optional(string, "bind")
      }
    )
  )
  default = null
}

variable "ports" {
  description = "List of ports to expose from the container"
  type = object(
    {
      internal = number
      external = number
      protocol = optional(string, "tcp")
    }
  )
  default = {
    internal = 443
    external = 50000
  }
}

variable "mirrored_registries" {
  description = "List of registries to mirror"
  type        = list(string)
  default = [
    "docker.io",
    "ghcr.io",
    "k8s.gcr.io",
    "oci.external-secrets.io",
    "public.ecr.aws",
    "quay.io",
    "registry-1.docker.io",
    "registry.k8s.io"
  ]
}

variable "domain" {
  type        = string
  description = "Domain name for the registry"
  default     = "k8s.dev.test"
}

variable "ca_path" {
  type = object(
    {
      crt = string
      key = string
    }
  )
  description = "Paths to the TLS certificate (CA and key) files"
}
