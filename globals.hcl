locals {
  root_path           = get_repo_root()
  ca_cert_path        = "${local.root_path}/.certs/rootCA.pem"
  key_cert_path       = "${local.root_path}/.certs/rootCA-key.pem"
  domain              = "k8s.dev.local"
  cluster_issuer_name = "own"
  registry_name       = "registry"
  registry_endpoint   = "${local.registry_name}:5000"
  registry_url        = "http://${local.registry_endpoint}"

  k8s_extra_mounts = [
    {
      host_path      = "${local.root_path}/local-storage"
      container_path = "/mnt/local-storage"
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
        containerd_config_patches = [
          <<-EOF
        kind: Cluster
        apiVersion: kind.x-k8s.io/v1alpha4
        containerdConfigPatches:
        - |-
          [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
            endpoint = [${local.registry_url}]
          [plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry-1.docker.io"]
            endpoint = [${local.registry_url}]
          [plugins."io.containerd.grpc.v1.cri".registry.mirrors."ghcr.io"]
            endpoint = [${local.registry_url}]
          [plugins."io.containerd.grpc.v1.cri".registry.mirrors."k8s.gcr.io"]
            endpoint = [${local.registry_url}]
          [plugins."io.containerd.grpc.v1.cri".registry.mirrors."quay.io"]
            endpoint = [${local.registry_url}]
          [plugins."io.containerd.grpc.v1.cri".registry.mirrors."public.ecr.aws"]
            endpoint = [${local.registry_url}]
          [plugins."io.containerd.grpc.v1.cri".registry.configs."${local.registry_endpoint}".tls]
            insecure_skip_verify = true
        EOF
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
      enabled = true
      inputs = {
        name = local.registry_name
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
        tls_crt             = fileexists(local.ca_cert_path) ? base64encode(file(local.ca_cert_path)) : "ci"
        tls_key             = fileexists(local.key_cert_path) ? base64encode(file(local.key_cert_path)) : "ci"
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
