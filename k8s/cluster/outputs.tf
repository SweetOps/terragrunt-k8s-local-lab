output "kubeconfig" {
  value     = kind_cluster.main.kubeconfig
  sensitive = true
}

output "cluster_name" {
  value = var.cluster_name
}

output "client_certificate" {
  value     = kind_cluster.main.client_certificate
  sensitive = true
}

output "client_key" {
  value     = kind_cluster.main.client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = kind_cluster.main.cluster_ca_certificate
  sensitive = true
}

output "endpoint" {
  value = kind_cluster.main.endpoint
}

output "pod_subnet" {
  value = kind_cluster.main.kind_config[0].networking[0].pod_subnet
}

output "service_subnet" {
  value = kind_cluster.main.kind_config[0].networking[0].service_subnet
}

output "api_server_port" {
  value = kind_cluster.main.kind_config[0].networking[0].api_server_port
}
