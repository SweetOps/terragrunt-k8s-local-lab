
locals {
  cluster_secret_store = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ClusterSecretStore"
    metadata = {
      name      = "vault"
      namespace = var.destination.namespace
      labels = {
        "app.kubernetes.io/name" = var.chart
      }
      annotations = {
        "argocd.argoproj.io/sync-wave" = "5"
      }
    }
    spec = {
      provider = {
        vault = {
          server = var.vault_url
          path   = vault_mount.main.path
          auth = {
            kubernetes = {
              mountPath = vault_auth_backend.main.path
              role      = vault_kubernetes_auth_backend_role.main.role_name
              serviceAccountRef = {
                name      = var.chart
                namespace = var.destination.namespace
              }
            }
          }
        }
      }
    }
  }
}

resource "vault_mount" "main" {
  path        = var.k8s_cluster_name
  type        = "kv"
  description = "Cluster ${var.k8s_cluster_name} secrets"

  options = {
    version = "2"
  }
}

resource "vault_auth_backend" "main" {
  type        = "kubernetes"
  path        = format("%s-kubernetes", var.k8s_cluster_name)
  description = "Kubernetes auth for external-secrets"
}

resource "vault_kubernetes_auth_backend_config" "main" {
  backend         = vault_auth_backend.main.path
  kubernetes_host = var.destination.server
}

data "vault_policy_document" "main" {
  rule {
    path         = format("%s/*", vault_mount.main.path)
    capabilities = ["read", "list"]
    description  = "Allow reading secrets from the mount path"
  }
}

resource "vault_policy" "main" {
  name   = format("%s-external-secrets", var.k8s_cluster_name)
  policy = data.vault_policy_document.main.hcl
}

resource "vault_kubernetes_auth_backend_role" "main" {
  backend                          = vault_auth_backend.main.path
  role_name                        = format("%s-external-secrets", var.k8s_cluster_name)
  bound_service_account_names      = [var.chart]
  bound_service_account_namespaces = [var.destination.namespace]
  token_policies                   = [vault_policy.main.name]
}
