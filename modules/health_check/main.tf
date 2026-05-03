resource "google_compute_health_check" "global" {
  count   = var.scope == "GLOBAL" ? 1 : 0
  project = var.project_id
  name    = var.name

  description = var.description

  check_interval_sec  = var.check_interval_sec
  timeout_sec         = var.timeout_sec
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold

  dynamic "http_health_check" {
    for_each = var.protocol == "HTTP" ? [1] : []
    content {
      port         = var.port
      request_path = var.request_path
      host         = var.host
    }
  }

  dynamic "https_health_check" {
    for_each = var.protocol == "HTTPS" ? [1] : []
    content {
      port         = var.port
      request_path = var.request_path
      host         = var.host
    }
  }

  log_config {
    enable = var.enable_log
  }
}

resource "google_compute_region_health_check" "regional" {
  count   = var.scope == "REGIONAL" ? 1 : 0
  project = var.project_id
  name    = var.name
  region  = var.region

  description = var.description

  check_interval_sec  = var.check_interval_sec
  timeout_sec         = var.timeout_sec
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold

  dynamic "http_health_check" {
    for_each = var.protocol == "HTTP" ? [1] : []
    content {
      port         = var.port
      request_path = var.request_path
      host         = var.host
    }
  }

  dynamic "https_health_check" {
    for_each = var.protocol == "HTTPS" ? [1] : []
    content {
      port         = var.port
      request_path = var.request_path
      host         = var.host
    }
  }

  log_config {
    enable = var.enable_log
  }
}
