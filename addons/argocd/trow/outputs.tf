output "url" {
  value       = format("https://%s", local.hostname)
  description = "The endpoint URL for the Trow registry."
}
