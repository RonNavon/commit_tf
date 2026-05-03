resource "google_compute_subnetwork" "this" {
  project                  = var.project_id
  name                     = var.name
  network                  = var.network
  region                   = var.region
  ip_cidr_range            = var.ip_cidr_range
  description              = var.description
  purpose                  = var.purpose
  role                     = var.role
  private_ip_google_access = var.private_ip_google_access
  stack_type               = var.stack_type

  dynamic "secondary_ip_range" {
    for_each = var.secondary_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = var.flow_logs_aggregation_interval
      flow_sampling        = var.flow_logs_sampling
      metadata             = var.flow_logs_metadata
    }
  }
}
