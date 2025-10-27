locals {
  path                = abspath(path.module)
  config_file         = "config.json"
  storage_path        = "${local.path}/../../local-storage/registry"
  target_storage_path = "/var/lib/registry"
  registries          = ["k8s.gcr.io", "docker.io", "ghcr.io", "quay.io", "public.ecr.aws"]
  registry_port       = var.ports[0].internal
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
            for r in local.registries : {
              urls      = ["https://${r}"]
              onDemand  = true
              tlsVerify = true

              content = [
                {
                  prefix      = "**"
                  destination = "/${r}"
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

resource "kubernetes_config_map_v1" "main" {
  metadata {
    name      = "local-registry-hosting"
    namespace = "kube-public"
  }

  data = {
    "localRegistryHosting.v1" = <<-EOF
host: "${module.registry.name}:${local.registry_port}"
help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF
  }
}
