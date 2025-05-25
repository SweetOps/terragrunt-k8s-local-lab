output "cluster_secret_store_name" {
  value = local.cluster_secret_store.metadata.name
}

output "vault_mount_path" {
  value = vault_mount.main.path
}
