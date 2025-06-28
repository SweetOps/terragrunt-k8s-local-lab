output "console_url" {
  value       = format("https://%s", try(yamldecode(data.utils_deep_merge_yaml.main.output)["tenant"]["features"]["domains"]["console"], ""))
  description = "The URL for accessing the MinIO console."
}

output "api_url" {
  value       = format("https://%s", try(yamldecode(data.utils_deep_merge_yaml.main.output)["tenant"]["features"]["domains"]["minio"][0], ""))
  description = "The URL for accessing the MinIO API."
}
