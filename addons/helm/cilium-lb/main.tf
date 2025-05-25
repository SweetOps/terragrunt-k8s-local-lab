locals {
  docker_container_name = format("%s-control-plane", var.k8s_cluster_name)
  docker_subnet         = local.docker_ipv4_networks[0].subnet

  docker_ipv4_networks = [
    for cidr in data.docker_network.main.ipam_config : cidr
    if can(cidrnetmask(cidr.subnet))
  ]

  values = {
    resources = [
      {
        apiVersion = "cilium.io/v2alpha1"
        kind       = "CiliumLoadBalancerIPPool"
        metadata = {
          name      = "lb-pool"
          namespace = "kube-system"
        }
        spec = {
          blocks = [
            {
              cidr = format("%s/32", cidrhost(local.docker_subnet, 200))
            }
          ]
        }
      },
      {
        apiVersion = "cilium.io/v2alpha1"
        kind       = "CiliumL2AnnouncementPolicy"
        metadata = {
          name      = "lb-policy"
          namespace = "kube-system"
        }
        spec = {
          externalIPs     = false
          loadBalancerIPs = true
          interfaces      = ["^eth[0-9]+"]
          nodeSelector = {
            matchExpressions = [
              {
                key      = "node-role.kubernetes.io/control-plane"
                operator = "DoesNotExist"
              }
            ]
          }

        }
      }
    ]
  }
}

data "docker_network" "main" {
  name = "kind"
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

