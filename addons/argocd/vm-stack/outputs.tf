output "grafana_url" {
  value       = format("https://%s", try(yamldecode((data.utils_deep_merge_yaml.main.output)["grafana"]["ingress"]["hosts"][0]), ""))
  description = "The URL for Grafana"
}

output "alertmanager_url" {
  value       = format("https://%s", try(yamldecode((data.utils_deep_merge_yaml.main.output)["alertmanager"]["ingress"]["hosts"][0]), ""))
  description = "The URL for Alertmanager"
}

output "vmsingle_url" {
  value       = format("https://%s", try(yamldecode((data.utils_deep_merge_yaml.main.output)["vmsingle"]["ingress"]["hosts"][0]), ""))
  description = "The URL for VM Single"
}
