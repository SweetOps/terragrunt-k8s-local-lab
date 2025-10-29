# We can't disable storage class creation in kind clusters, so we mark the default storage class as false

import {
  to = kubernetes_storage_class_v1.main
  id = "standard"
}

resource "kubernetes_storage_class_v1" "main" {
  metadata {
    name = "standard"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "false"
    }
  }
  storage_provisioner    = "rancher.io/local-path"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
}

resource "kubernetes_config_map_v1" "main" {
  metadata {
    name      = "local-registry-hosting"
    namespace = "kube-public"
  }

  data = {
    "localRegistryHosting.v1" = <<-EOF
host: "${var.registry_endpoint}"
EOF
  }
}
