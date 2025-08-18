resource "docker_image" "main" {
  name = var.image
}

resource "docker_container" "main" {
  name       = var.name
  image      = docker_image.main.image_id
  command    = var.command
  env        = var.env
  privileged = var.privileged
  entrypoint = var.entrypoint
  restart    = var.restart

  dynamic "networks_advanced" {
    for_each = var.networks_advanced != null ? [var.networks_advanced] : []
    content {
      name         = networks_advanced.value.name
      ipv4_address = networks_advanced.value.ipv4_address
      ipv6_address = networks_advanced.value.ipv6_address
    }
  }

  dynamic "mounts" {
    for_each = var.mounts != null ? var.mounts : []
    content {
      type      = mounts.value.type
      source    = mounts.value.source
      target    = mounts.value.target
      read_only = mounts.value.read_only
    }
  }

  dynamic "ports" {
    for_each = var.ports != null ? var.ports : []
    content {
      internal = ports.value.internal
      external = ports.value.external
      protocol = ports.value.protocol
    }
  }
}
