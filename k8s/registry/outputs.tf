output "name" {
  description = "Name of the Zot-registry Docker container"
  value       = module.registry.name
}

output "ip_address" {
  description = "IP address of the Zot-registry Docker container"
  value       = module.registry.ip_address
}

output "url" {
  description = "URL of the Zot-registry"
  value       = local.registry_url
}

output "endpoint" {
  description = "Endpoint of the Zot-registry"
  value       = local.registry_endpoint
}

output "containerd_config_patch" {
  description = "Containerd config patch"
  value       = <<-EOF
%{for r in var.mirrored_registries}
[plugins."io.containerd.grpc.v1.cri".registry.mirrors."${r}"]
  endpoint = ["${local.registry_url}/v2/${r}"]
%{endfor}
[plugins."io.containerd.grpc.v1.cri".registry.configs."${local.registry_endpoint}".tls]
  insecure_skip_verify = true
EOF
}
