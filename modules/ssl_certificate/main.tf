locals {
  is_managed = var.mode == "MANAGED"
  is_self    = var.mode == "SELF_MANAGED"
}

# Cross-variable assertion: Google-managed certs are global-only.
resource "terraform_data" "validate" {
  lifecycle {
    precondition {
      condition     = !(var.mode == "MANAGED" && var.scope == "REGIONAL")
      error_message = "Google-managed SSL certificates are only supported with scope = GLOBAL."
    }
  }
}

# Google-managed (global only)
resource "google_compute_managed_ssl_certificate" "managed" {
  count   = local.is_managed && var.scope == "GLOBAL" ? 1 : 0
  project = var.project_id
  name    = var.name

  managed {
    domains = var.domains
  }
}

# Self-managed global
resource "google_compute_ssl_certificate" "self_global" {
  count   = local.is_self && var.scope == "GLOBAL" ? 1 : 0
  project = var.project_id
  name    = var.name

  certificate = var.certificate_pem
  private_key = var.private_key_pem
  description = var.description

  lifecycle {
    create_before_destroy = true
  }
}

# Self-managed regional
resource "google_compute_region_ssl_certificate" "self_regional" {
  count   = local.is_self && var.scope == "REGIONAL" ? 1 : 0
  project = var.project_id
  region  = var.region
  name    = var.name

  certificate = var.certificate_pem
  private_key = var.private_key_pem
  description = var.description

  lifecycle {
    create_before_destroy = true
  }
}
