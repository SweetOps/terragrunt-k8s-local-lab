locals {
  inputs = try(read_terragrunt_config(find_in_parent_folders("globals.hcl")), {})
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

inputs = merge(
  try(local.inputs.locals.k8s.cluster.inputs, {}),
  {
    containerd_config_patches = [dependency.registry.outputs.containerd_config_patch]
  }
)
