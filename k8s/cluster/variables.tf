variable "cluster_name" {
  type        = string
  default     = "dev"
  description = "Kind cluster name"
}

variable "node_image" {
  type        = string
  default     = "kindest/node:v1.34.0"
  description = "Node image to use for the cluster"
}

variable "kubeconfig_path" {
  type        = string
  default     = ""
  description = "Path to the kubeconfig file"
}

variable "containerd_config_patches" {
  type        = list(string)
  default     = []
  description = "Containerd config patches"
}

variable "feature_gates" {
  type        = map(string)
  default     = {}
  description = "Kubeadm feature gates"
}

variable "runtime_config" {
  type        = map(string)
  default     = {}
  description = "Kubeadm runtime configuration options"
}

variable "control_plane_node" {
  type = object(
    {
      kubeadm_config_patches = optional(list(string), [])
      extra_mounts = optional(
        list(
          object(
            {
              host_path       = string
              container_path  = string
              read_only       = optional(bool, false)
              selinux_relabel = optional(bool, false)
              propagation     = optional(string, "None")
            }
          )
        ),
        []
      )
    }
  )
  default = {}
}

variable "worker_nodes" {
  type = list(
    object(
      {
        kubeadm_config_patches = list(string)
        extra_mounts = optional(
          list(
            object(
              {
                host_path       = string
                container_path  = string
                read_only       = optional(bool, false)
                selinux_relabel = optional(bool, false)
                propagation     = optional(string, "None")
              }
            )
          ),
          []
        )
      }
    )
  )

  default = []
}

variable "cluster_network" {
  type = object(
    {
      disable_default_cni = optional(bool, true)
      kube_proxy_mode     = optional(string, "none")
      api_server_port     = optional(number, 6443)
      pod_subnet          = optional(string, "10.244.0.0/16")
      service_subnet      = optional(string, "10.96.0.0/12")
    }
  )
  default = {}
}
