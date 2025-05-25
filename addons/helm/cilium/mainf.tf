locals {
  values = {
    ipam = {
      mode = "kubernetes"
    }
    hubble = {
      enabled = false
      ui = {
        enabled = false
      }
      relay = {
        enabled = false
      }
    }
    kubeProxyReplacement = true
    loadBalancer = {
      algorithm = "maglev"
    }
    k8sServicePort = var.k8s_api_server_port
    k8sServiceHost = format("%s-control-plane", var.k8s_cluster_name)

    l2announcements = {
      enabled = true
    }
    externalIPs = {
      enabled = true
    }
    autoDirectNodeRoutes  = true
    routingMode           = "native"
    ipv4NativeRoutingCIDR = var.k8s_pod_subnet
  }
}

module "helm" {
  source = "../../../modules/helm"

  name              = var.name
  repository        = var.repository
  chart             = var.chart
  chart_version     = var.chart_version
  namespace         = var.namespace
  create_namespace  = var.create_namespace
  max_history       = var.max_history
  dependency_update = var.dependency_update
  reuse_values      = var.reuse_values
  wait              = var.wait
  timeout           = var.timeout
  values            = data.utils_deep_merge_yaml.main.output
}

data "utils_deep_merge_yaml" "main" {
  input = [
    yamlencode(local.values),
    var.override_values,
  ]
}
