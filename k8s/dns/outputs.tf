output "etcd_ip_address" {
  description = "The IP address of the CoreDNS container"
  value       = module.etcd.ip_address
}

output "etcd_name" {
  description = "The name of the etcd container"
  value       = module.etcd.name
}

output "coredns_ip_address" {
  description = "The IP address of the CoreDNS container"
  value       = module.coredns.ip_address
}

output "coredns_name" {
  description = "The name of the CoreDNS container"
  value       = module.coredns.name
}
