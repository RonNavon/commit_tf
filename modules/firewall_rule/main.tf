resource "google_compute_firewall" "this" {
  project   = var.project_id
  name      = var.name
  network   = var.network
  direction = var.direction
  priority  = var.priority

  description = var.description

  source_ranges           = var.direction == "INGRESS" ? var.source_ranges : null
  destination_ranges      = var.direction == "EGRESS" ? var.destination_ranges : null
  source_tags             = var.source_tags
  target_tags             = var.target_tags
  source_service_accounts = var.source_service_accounts
  target_service_accounts = var.target_service_accounts

  disabled = var.disabled

  dynamic "allow" {
    for_each = var.allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = var.deny
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }

  dynamic "log_config" {
    for_each = var.enable_logging ? [1] : []
    content {
      metadata = var.log_metadata
    }
  }
}
