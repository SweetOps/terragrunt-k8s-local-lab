output "url" {
  value       = format("https://%s", local.hostname)
  description = "The URL for accessing the ArgoCD."
}
