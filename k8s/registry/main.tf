locals {
  path                   = abspath(path.module)
  config_file            = "config.json"
  storage_path           = "${local.path}/../../local-storage/registry"
  target_storage_path    = "/var/lib/registry"
  registry_port          = var.ports.internal
  registry_host_port     = var.ports.external
  registry_endpoint      = format("%s:%d", module.registry.name, local.registry_port)
  registry_host_endpoint = format("%s:%d", "localhost", local.registry_host_port)
  registry_url           = "https://${local.registry_endpoint}"
  registry_host_url      = "https://${local.registry_host_endpoint}"
}

resource "local_file" "registry" {
  content = jsonencode(
    {
      storage = {
        rootDirectory = local.target_storage_path
      }
      http = {
        address = "0.0.0.0"
        port    = local.registry_port
        tls = {
          cert = format("%s/%s", local.target_storage_path, local.cert_file_name)
          key  = format("%s/%s", local.target_storage_path, local.key_file_name)
        }
      }
      extensions = {
        ui = {
          enable = true
        }
        search = {
          enable = true
        }
        sync = {
          enable = true
          registries = [
            for r in var.mirrored_registries : {
              urls      = formatlist("https://%s", [r, "${r}/v2/"])
              onDemand  = true
              tlsVerify = true

              content = [
                {
                  prefix      = "**"
                  destination = r
                }
              ]
            }
          ]
        }
      }
    }
  )
  filename = "${local.storage_path}/${local.config_file}"
}

module "registry" {
  source = "../../modules/docker-container"

  name              = var.name
  image             = var.image
  entrypoint        = var.entrypoint
  command           = var.command
  restart           = var.restart
  privileged        = var.privileged
  networks_advanced = var.networks_advanced
  ports             = [var.ports]
  env               = var.env

  mounts = coalescelist(
    var.mounts,
    [
      {
        source = local_file.registry.filename
        target = "/etc/zot/${local.config_file}"
      },
      {
        source = local.storage_path
        target = local.target_storage_path
      }
    ]
  )
}
