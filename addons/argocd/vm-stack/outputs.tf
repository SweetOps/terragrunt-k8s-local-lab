output "grafana_url" {
  value = format("https://%s", local.grafana_hostname)
}

output "alertmanager_url" {
  value = format("https://%s", local.alertmanager_hostname)
}

output "vmsingle_url" {
  value = format("https://%s", local.vmsingle_hostname)
}
