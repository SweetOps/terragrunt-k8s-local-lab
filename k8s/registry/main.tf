locals {
  path                = abspath(path.module)
  config_file         = "config.json"
  storage_path        = "${local.path}/../../local-storage/registry"
  target_storage_path = "/var/lib/registry"
  registry_port       = var.ports[0].internal
  registry_endpoint   = format("%s:%d", module.registry.name, local.registry_port)
  registry_url        = "http://${local.registry_endpoint}"
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
              urls      = ["https://${r}", "https://${r}/v2/"]
              onDemand  = true
              tlsVerify = true

              content = [
                {
                  prefix      = "**"
                  destination = "${r}"
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
  networks_advanced = var.networks_advanced
  ports             = var.ports
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

