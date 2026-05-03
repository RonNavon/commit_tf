resource "google_compute_target_https_proxy" "global" {
  count            = var.scope == "GLOBAL" ? 1 : 0
  project          = var.project_id
  name             = var.name
  url_map          = var.url_map
  ssl_certificates = var.ssl_certificates
  ssl_policy       = var.ssl_policy
  quic_override    = var.quic_override
}

resource "google_compute_region_target_https_proxy" "regional" {
  count            = var.scope == "REGIONAL" ? 1 : 0
  project          = var.project_id
  region           = var.region
  name             = var.name
  url_map          = var.url_map
  ssl_certificates = var.ssl_certificates
  ssl_policy       = var.ssl_policy
}
