resource "kind_cluster" "main" {
  name            = var.cluster_name
  node_image      = var.node_image
  wait_for_ready  = true
  kubeconfig_path = var.kubeconfig_path

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role                   = "control-plane"
      kubeadm_config_patches = var.control_plane_node.kubeadm_config_patches

      dynamic "extra_mounts" {
        for_each = var.control_plane_node.extra_mounts
        content {
          host_path       = extra_mounts.value.host_path
          container_path  = extra_mounts.value.container_path
          read_only       = extra_mounts.value.read_only
          selinux_relabel = extra_mounts.value.selinux_relabel
          propagation     = extra_mounts.value.propagation
        }
      }
    }

    dynamic "node" {
      for_each = var.worker_nodes
      content {
        role                   = "worker"
        kubeadm_config_patches = node.value.kubeadm_config_patches

        dynamic "extra_mounts" {
          for_each = node.value.extra_mounts
          content {
            host_path       = extra_mounts.value.host_path
            container_path  = extra_mounts.value.container_path
            read_only       = extra_mounts.value.read_only
            selinux_relabel = extra_mounts.value.selinux_relabel
            propagation     = extra_mounts.value.propagation
          }
        }
      }
    }

    containerd_config_patches = var.containerd_config_patches


    networking {
      disable_default_cni = var.cluster_network.disable_default_cni
      kube_proxy_mode     = var.cluster_network.kube_proxy_mode
      pod_subnet          = var.cluster_network.pod_subnet
      service_subnet      = var.cluster_network.service_subnet
      api_server_port     = var.cluster_network.api_server_port
    }
  }
}
