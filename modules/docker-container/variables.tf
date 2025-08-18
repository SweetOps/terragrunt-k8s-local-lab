variable "name" {
  description = "Name of the container"
  type        = string
}

variable "image" {
  description = "Docker image to use for the container"
  type        = string
}

variable "command" {
  description = "Command to run in the container"
  type        = list(string)
  default     = []
}

variable "entrypoint" {
  description = "Entrypoint for the container"
  type        = list(string)
  default     = []
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
  default = null
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
