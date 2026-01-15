locals {
  cert_file_name = "${var.name}.crt"
  key_file_name  = "${var.name}.key"
}

resource "tls_private_key" "main" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "main" {
  private_key_pem = tls_private_key.main.private_key_pem
  dns_names = [
    var.name,
    format("%s.%s", var.name, var.domain),
    "localhost",
    "127.0.0.1",
  ]

  subject {
    common_name = format("%s.%s", var.name, var.domain)
  }
}

resource "tls_locally_signed_cert" "main" {
  cert_request_pem      = tls_cert_request.main.cert_request_pem
  ca_private_key_pem    = file(var.ca_path.key)
  ca_cert_pem           = file(var.ca_path.crt)
  validity_period_hours = 8760

  allowed_uses = [
    "digital_signature",
    "key_agreement",
    "server_auth",
    "client_auth",
  ]

  set_subject_key_id = true
}

resource "local_sensitive_file" "cert" {
  content  = tls_locally_signed_cert.main.cert_pem
  filename = format("%s/%s", local.storage_path, local.cert_file_name)
}

resource "local_sensitive_file" "key" {
  content  = tls_private_key.main.private_key_pem
  filename = format("%s/%s", local.storage_path, local.key_file_name)
}
