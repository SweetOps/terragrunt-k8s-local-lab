output "url" {
  value       = format("https://%s", try(yamldecode(data.utils_deep_merge_yaml.main.output)["trow"]["domain"], ""))
  description = "The endpoint URL for Trow registry."
}
