output "token" {
  value     = local.token
  sensitive = true
}

output "url" {
  value = format("https://%s", local.hostname)
}

output "internal_url" {
  value = format("http://%s.%s.svc.cluster.local.:8200", var.chart, var.destination.namespace)
}
