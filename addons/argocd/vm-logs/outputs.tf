output "url" {
  value       = format("https://%s", try(yamldecode(data.utils_deep_merge_yaml.main.output)["server"]["ingress"]["hosts"][0]["name"], ""))
  description = "The URL of the VM Logs"
}
