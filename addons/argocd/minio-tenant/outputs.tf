output "console_url" {
  value       = format("https://%s", local.console_hostname)
  description = "The URL for accessing the MinIO console."
}

output "api_url" {
  value       = format("https://%s", local.api_hostname)
  description = "The URL for accessing the MinIO API."
}
