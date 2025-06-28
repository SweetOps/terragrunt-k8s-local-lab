generate "provider" {
  path      = "tg-helm-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
provider "helm" {
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
