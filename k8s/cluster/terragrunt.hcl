locals {
  inputs = try(read_terragrunt_config(find_in_parent_folders("globals.hcl")), {})
}

dependency "registry" {
  config_path = "${get_path_to_repo_root()}/k8s/registry"
  mock_outputs = {
    name       = "test-registry"
    ip_address = "10.0.0.1"
    url        = "http://10.0.0.1:5000"
    endpoint   = "10.0.0.1:5000"
  }
}

inputs = merge(
  try(local.inputs.locals.k8s.cluster.inputs, {}),
  {
    containerd_config_patches = [
      <<-EOF
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."${dependency.registry.outputs.endpoint}"]
          endpoint = ["${dependency.registry.outputs.url}"]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          endpoint = ["${dependency.registry.outputs.url}"]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry-1.docker.io"]
          endpoint = ["${dependency.registry.outputs.url}"]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."ghcr.io"]
          endpoint = ["${dependency.registry.outputs.url}"]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."k8s.gcr.io"]
          endpoint = ["${dependency.registry.outputs.url}"]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."quay.io"]
          endpoint = ["${dependency.registry.outputs.url}"]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."public.ecr.aws"]
          endpoint = ["${dependency.registry.outputs.url}"]
        [plugins."io.containerd.grpc.v1.cri".registry.configs."${dependency.registry.outputs.endpoint}".tls]
          insecure_skip_verify = true
        EOF
    ]
  }
)
