output "etcd_ip_address" {
  description = "The IP address of the CoreDNS container"
  value       = module.etcd.ip_address
}

output "coredns_ip_address" {
  description = "The IP address of the CoreDNS container"
  value       = module.coredns.ip_address
}
