locals {
  is_global = var.scope == "GLOBAL"
}

resource "google_compute_global_forwarding_rule" "global" {
  count                 = local.is_global ? 1 : 0
  project               = var.project_id
  name                  = var.name
  target                = var.target
  port_range            = var.port_range
  ip_protocol           = var.ip_protocol
  load_balancing_scheme = var.load_balancing_scheme
  ip_address            = var.ip_address
  labels                = var.labels
}

resource "google_compute_forwarding_rule" "regional" {
  count                 = local.is_global ? 0 : 1
  project               = var.project_id
  region                = var.region
  name                  = var.name
  target                = var.target
  port_range            = var.port_range
  ip_protocol           = var.ip_protocol
  load_balancing_scheme = var.load_balancing_scheme
  network               = var.network
  subnetwork            = var.subnetwork
  ip_address            = var.ip_address
  labels                = var.labels
  allow_global_access   = var.allow_global_access
}
