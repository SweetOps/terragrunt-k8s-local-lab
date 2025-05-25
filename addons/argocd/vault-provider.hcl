generate "vault_provider" {
  path      = "tg-vault-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
provider "vault" {
  address  = "${dependency.vault.outputs.url}:443"
  token    = "${dependency.vault.outputs.token}"
}
EOF
}
