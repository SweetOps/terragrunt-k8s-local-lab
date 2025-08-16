output "id" {
  description = "The ID of the created container"
  value       = docker_container.main.id
}

output "name" {
  description = "The name of the created container"
  value       = docker_container.main.name
}

output "ip_address" {
  description = "The IP address of the created container"
  value       = try(docker_container.main.network_data[0].ip_address, null)
}
