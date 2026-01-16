locals {
  docker_subnet        = local.docker_ipv4_networks[0].subnet
  chart_name           = "cilium"
  chart_version_suffix = time_static.chart_version_suffix.unix
  chart_version        = format("%s-%s", var.chart_version, local.chart_version_suffix)
  chart_dir            = dirname(local_file.rendered_chart_yaml.filename)
  host_repository      = "oci://${var.registry_endpoints.host}/helm-charts"
  repository           = "${var.registry_endpoints.in_cluster}/helm-charts"

  docker_ipv4_networks = [
    for cidr in data.docker_network.main.ipam_config : cidr
    if can(cidrnetmask(cidr.subnet))
  ]

  chart_yaml = {
    apiVersion  = "v2"
    appVersion  = "1.0.0"
    description = "A Helm chart for Cilium"
    name        = local.chart_name
    version     = local.chart_version
    dependencies = [
      {
        name       = var.chart
        version    = var.chart_version
        repository = var.repository
      }
    ]
  }

  values = {
    fullNameOverride = "cilium"
    loadBalancerIPPools = [
      {
        cidr = format("%s/32", cidrhost(local.docker_subnet, 200))
      }
    ]
    cilium = {
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
}

resource "time_static" "chart_version_suffix" {
  triggers = {
    chart_version = var.chart_version
    repository    = var.repository
    chart         = var.chart
  }
}

resource "local_file" "rendered_chart_yaml" {
  content              = yamlencode(local.chart_yaml)
  filename             = "${path.module}/chart/Chart.yaml"
  directory_permission = "0755"
  file_permission      = "0644"
}

resource "terraform_data" "push_chart" {
  input = local.chart_version

  provisioner "local-exec" {
    command = <<EOF
    set -e

    rm -f ${local.chart_dir}/*.tgz
    helm package ${local.chart_dir} -u -d ${local.chart_dir}
    mv ${local.chart_dir}/*.tgz ${local.chart_dir}/${local.chart_name}.tgz
    helm push ${local.chart_dir}/${local.chart_name}.tgz ${local.host_repository}
    rm ${local.chart_dir}/${local.chart_name}.tgz
    EOF
  }

  triggers_replace = [
    time_static.chart_version_suffix.unix,
    local.chart_version,
    local.host_repository
  ]
}

data "docker_network" "main" {
  name = "kind"
}

resource "argocd_repository" "main" {
  name       = local.chart_name
  repo       = local.repository
  type       = "helm"
  insecure   = true
  enable_oci = true
}

module "cilium" {
  source = "../../../modules/argocd"

  chart         = argocd_repository.main.name
  repository    = argocd_repository.main.repo
  chart_version = terraform_data.push_chart.output
  metadata      = var.metadata
  destination   = var.destination
  cascade       = var.cascade
  wait          = var.wait
  sync_policy   = var.sync_policy
  sync_options  = var.sync_options
  retry         = var.retry
  values        = data.utils_deep_merge_yaml.main.output
}

data "utils_deep_merge_yaml" "main" {
  input = [
    yamlencode(local.values),
    var.override_values,
  ]
}
