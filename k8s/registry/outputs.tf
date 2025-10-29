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
