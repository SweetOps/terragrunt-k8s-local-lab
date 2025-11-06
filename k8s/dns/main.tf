resource "local_file" "coredns_config" {
  content  = <<EOT
.:53 {
    etcd ${var.domain} {
        stubzones
        path /skydns
        endpoint http://${module.etcd.name}:2379
    }
    header {
        response set ra
    }
    forward . 8.8.8.8
    log
    errors
}
EOT
  filename = "${abspath(path.module)}/Corefile"
}

module "etcd" {
  source = "../../modules/docker-container"

  name              = var.etcd_name
  image             = var.etcd_image
  command           = var.etcd_command
  networks_advanced = var.etcd_networks_advanced
  mounts            = var.etcd_mounts
  ports             = var.etcd_ports
  env               = var.etcd_env
}

module "coredns" {
  source = "../../modules/docker-container"

  name              = var.coredns_name
  image             = var.coredns_image
  command           = var.coredns_command
  entrypoint        = var.coredns_entrypoint
  privileged        = var.coredns_privileged
  networks_advanced = var.coredns_networks_advanced
  ports             = var.coredns_ports

  mounts = coalescelist(
    var.coredns_mounts,
    [
      {
        source = local_file.coredns_config.filename
        target = "/Corefile"
      }
    ]
  )

  depends_on = [
    module.etcd
  ]
}
