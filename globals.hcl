locals {
  root_path     = get_repo_root()
  ca_cert_path  = "${local.root_path}/.certs/rootCA.pem"
  key_cert_path = "${local.root_path}/.certs/rootCA-key.pem"

  k8s_extra_mounts = [
    {
      host_path      = "${local.root_path}/local-storage"
      container_path = "/mnt/local-storage"
    }
  ]
  k8s = {
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
  helm = {
    # cilium = {}
    # argocd = {}
  }

  argocd = {
    cert_manager = {
      tls_crt = fileexists(local.ca_cert_path) ? base64encode(file(local.ca_cert_path)) : "ci"
      tls_key = fileexists(local.key_cert_path) ? base64encode(file(local.key_cert_path)) :"ci"
    }
    # ingress_nginx = {}
    # argocd        = {}
  }
}
