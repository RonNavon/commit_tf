locals {
  use_global = var.scope == "GLOBAL"
}

resource "google_compute_backend_service" "global" {
  count   = local.use_global ? 1 : 0
  project = var.project_id
  name    = var.name

  description = var.description
  protocol    = var.protocol
  port_name   = var.port_name
  timeout_sec = var.timeout_sec

  load_balancing_scheme = var.load_balancing_scheme
  enable_cdn            = var.enable_cdn

  health_checks = [var.health_check]

  security_policy = var.security_policy

  log_config {
    enable      = var.log_enable
    sample_rate = var.log_sample_rate
  }

  dynamic "backend" {
    for_each = var.backends
    content {
      group                 = backend.value.group
      balancing_mode        = backend.value.balancing_mode
      max_rate_per_endpoint = backend.value.max_rate_per_endpoint
      capacity_scaler       = backend.value.capacity_scaler
    }
  }

  dynamic "iap" {
    for_each = var.iap == null ? [] : [var.iap]
    content {
      enabled              = true
      oauth2_client_id     = iap.value.oauth2_client_id
      oauth2_client_secret = iap.value.oauth2_client_secret
    }
  }
}

resource "google_compute_region_backend_service" "regional" {
  count   = local.use_global ? 0 : 1
  project = var.project_id
  region  = var.region
  name    = var.name

  description = var.description
  protocol    = var.protocol
  port_name   = var.port_name
  timeout_sec = var.timeout_sec

  load_balancing_scheme = var.load_balancing_scheme

  health_checks = [var.health_check]

  log_config {
    enable      = var.log_enable
    sample_rate = var.log_sample_rate
  }

  dynamic "backend" {
    for_each = var.backends
    content {
      group           = backend.value.group
      balancing_mode  = backend.value.balancing_mode
      capacity_scaler = backend.value.capacity_scaler
    }
  }
}
