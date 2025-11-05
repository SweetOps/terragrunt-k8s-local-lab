locals {
  exclude = !feature.initial_apply.value
}

dependency "k8s" {
  config_path = "${get_path_to_repo_root()}/k8s/cluster"
  mock_outputs = {
    endpoint               = "https://test.k8s.dev"
    client_key             = "test_client_key"
    client_certificate     = "test_client_certificate"
    cluster_ca_certificate = "test_cluster_ca_certificate"
    pod_subnet             = "10.244.0.0/16"
    service_subnet         = "10.96.0.0/12"
    api_server_port        = 6443
    cluster_name           = "test"
  }
}

dependency "registry" {
  config_path = "${get_path_to_repo_root()}/k8s/registry"
  mock_outputs = {
    name                    = "test-registry"
    ip_address              = "10.0.0.1"
    url                     = "http://10.0.0.1:5000"
    endpoint                = "10.0.0.1:5000"
    containerd_config_patch = "mock"
  }
}

generate "k8s_provider" {
  path      = "tg-k8s-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
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
EOF
}

inputs = {
  registry_endpoint = dependency.registry.outputs.endpoint
}

feature "initial_apply" {
  default = false
}

exclude {
  if      = local.exclude
  actions = ["plan", "apply", "destroy", "output"]
}
