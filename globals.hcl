locals {
  root_path           = get_repo_root()
  cert_path           = "${local.root_path}/.certs"
  ca_cert_path        = "${local.cert_path}/rootCA.pem"
  key_cert_path       = "${local.cert_path}/rootCA-key.pem"
  domain              = "k8s.dev.local"
  cluster_issuer_name = "own"

  k8s_extra_mounts = [
    {
      host_path      = "${local.root_path}/local-storage"
      container_path = "/mnt/local-storage"
    },
    {
      host_path      = local.ca_cert_path
      container_path = "/etc/ssl/certs/rootCA.pem"
    }
  ]

  k8s = {
    cluster = {
      inputs = {
        kubeconfig_path = "${local.root_path}/KUBECONFIG"
        worker_nodes = [
          {
            kubeadm_config_patches = [
              <<-EOF
        kind: JoinConfiguration
        nodeRegistration:
          kubeletExtraArgs:
              node-labels: "role=workload"
        EOF
            ]
            extra_mounts = local.k8s_extra_mounts
          }
        ]
      }
    }
    dns = {
      enabled = true
      inputs = {
        domain = local.domain
      }
    }
    registry = {
      inputs = {
        name = "registry"
        ca_path = {
          crt = local.ca_cert_path
          key = local.key_cert_path
        }
      }
    }
  }
  helm = {
    # cilium = {
    #   enabled = true
    #   inputs = {}
    # }
  }

  argocd = {
    cassandra_operator = {
      enabled = false
    }
    cert_manager = {
      inputs = {
        cluster_issuer_name = local.cluster_issuer_name
        tls_path = {
          crt = local.ca_cert_path
          key = local.key_cert_path
        }
      }
    }
    clickhouse_operator = {
      enabled = false
    }
    grafana_operator = {
      enabled = false
    }
    kafka_operator = {
      enabled = false
    }
    temporal_operator = {
      enabled = false
    }
    vm_logs = {
      enabled = false
    }
    vm_operator = {
      enabled = false
    }
    vm_stack = {
      enabled = false
    }
  }
}
