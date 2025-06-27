feature "initial_apply" {
  default = false
}

generate "provider" {
  path      = "tg-argocd-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
data "kubernetes_secret" "argocd" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
}

provider "kubernetes" {
    host                   = "${dependency.k8s.outputs.endpoint}"
    client_key             = <<-KEY
${dependency.k8s.outputs.client_key}
KEY
    client_certificate     = <<-CERT
${dependency.k8s.outputs.client_certificate}"
CERT
    cluster_ca_certificate = <<-CA
${dependency.k8s.outputs.cluster_ca_certificate}
CA
}

provider "argocd" {
  username                    = "admin"
  password                    = data.kubernetes_secret.argocd.data.password
  plain_text                  = true
  port_forward_with_namespace = "argocd"

  kubernetes {
    host                   = "${dependency.k8s.outputs.endpoint}"
    client_key             = <<-KEY
${dependency.k8s.outputs.client_key}
KEY
    client_certificate     = <<-CERT
${dependency.k8s.outputs.client_certificate}"
CERT
    cluster_ca_certificate = <<-CA
${dependency.k8s.outputs.cluster_ca_certificate}
CA
  }
}
EOF
}
