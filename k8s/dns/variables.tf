variable "domain" {
  description = "The domain name that will be served by CoreDNS"
  type        = string
}

variable "coredns_name" {
  description = "Name of the CoreDNS container"
  type        = string
  default     = "coredns"
}

variable "coredns_image" {
  description = "Docker image to use for the CoreDNS container"
  type        = string
  default     = "coredns/coredns:1.12.3"
}

variable "coredns_privileged" {
  description = "Run the container the CoreDNS in privileged mode"
  type        = bool
  default     = true
}

variable "coredns_command" {
  description = "Command to run in the CoreDNS container"
  type        = list(string)
  default     = ["-conf", "/Corefile"]
}

variable "coredns_entrypoint" {
  description = "Entrypoint for the CoreDNS container"
  type        = list(string)
  default     = ["/coredns"]
}

variable "coredns_networks_advanced" {
  description = "Advanced network settings for the CoreDNS container"
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

variable "coredns_mounts" {
  description = "List of mounts for the CoreDNS container"
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

variable "coredns_ports" {
  description = "List of ports to expose from the CoreDNS container"
  type = list(
    object(
      {
        internal = number
        external = number
        protocol = optional(string, "tcp")
      }
    )
  )
  default = [
    {
      internal = 53
      external = 53
      protocol = "udp"
    },
    {
      internal = 53
      external = 53
      protocol = "tcp"
    }
  ]
}

variable "etcd_name" {
  description = "Name of the ETCD container"
  type        = string
  default     = "etcd"
}

variable "etcd_image" {
  description = "Docker image to use for the ETCD container"
  type        = string
  default     = "quay.io/coreos/etcd:v3.5.9"
}

variable "etcd_command" {
  description = "Command to run in the ETCD container"
  type        = list(string)
  default = [
    "etcd",
    "--advertise-client-urls", "http://0.0.0.0:2379",
    "--listen-client-urls", "http://0.0.0.0:2379"
  ]
}

variable "etcd_env" {
  description = "Environment variables to set in the ETCD container"
  type        = list(string)
  default     = []
}

variable "etcd_networks_advanced" {
  description = "Advanced network settings for the ETCD container"
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

variable "etcd_mounts" {
  description = "List of mounts for the ETCD container"
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

variable "etcd_ports" {
  description = "List of ports to expose from the ETCD container"
  type = list(
    object(
      {
        internal = number
        external = number
        protocol = optional(string, "tcp")
      }
    )
  )
  default = null
}
