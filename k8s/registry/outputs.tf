output "name" {
  description = "Name of the Zot-registry Docker container"
  value       = module.registry.name
}

output "ip_address" {
  description = "IP address of the Zot-registry Docker container"
  value       = module.registry.ip_address
}
