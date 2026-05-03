resource "google_container_node_pool" "this" {
  project    = var.project_id
  name       = var.name
  cluster    = var.cluster_name
  location   = var.location
  node_count = var.autoscaling.enabled ? null : var.node_count

  dynamic "autoscaling" {
    for_each = var.autoscaling.enabled ? [1] : []
    content {
      min_node_count  = var.autoscaling.min_node_count
      max_node_count  = var.autoscaling.max_node_count
      location_policy = var.autoscaling.location_policy
    }
  }

  management {
    auto_repair  = var.auto_repair
    auto_upgrade = var.auto_upgrade
  }

  upgrade_settings {
    strategy        = var.upgrade_strategy
    max_surge       = var.max_surge
    max_unavailable = var.max_unavailable
  }

  node_config {
    machine_type    = var.machine_type
    disk_size_gb    = var.disk_size_gb
    disk_type       = var.disk_type
    image_type      = var.image_type
    service_account = var.service_account
    oauth_scopes    = var.oauth_scopes
    labels          = var.labels
    tags            = var.tags
    preemptible     = var.preemptible
    spot            = var.spot

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    metadata = merge(
      { "disable-legacy-endpoints" = "true" },
      var.metadata,
    )
  }
}
