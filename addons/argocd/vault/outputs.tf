output "token" {
  value     = local.token
  sensitive = true
}

output "url" {
  value = format("https://%s", try(yamldecode((data.utils_deep_merge_yaml.main.output)["ingress"]["hosts"][0]), ""))
}

output "internal_url" {
  value = format("http://%s.%s.svc.cluster.local.:8200", var.chart, var.destination.namespace)
}
