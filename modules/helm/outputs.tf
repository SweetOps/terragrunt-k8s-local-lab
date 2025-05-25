output "metadata" {
  value       = helm_release.main.metadata
  description = "Block status of the deployed helm release"
}
