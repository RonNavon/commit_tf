resource "google_container_cluster" "this" {
  provider = google
  project  = var.project_id
  name     = var.name
  location = var.location

  # We always manage node pools separately.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

  deletion_protection = var.deletion_protection
  networking_mode     = "VPC_NATIVE"
  datapath_provider   = var.datapath_provider

  release_channel {
    channel = var.release_channel
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.enable_private_nodes ? var.master_ipv4_cidr_block : null

    dynamic "master_global_access_config" {
      for_each = var.enable_private_nodes ? [1] : []
      content {
        enabled = var.master_global_access
      }
    }
  }

  # Only emit the lockdown block when the caller actually provides a list.
  # Empty list = master endpoint accepts from any source (still requires auth).
  dynamic "master_authorized_networks_config" {
    for_each = length(var.master_authorized_networks) > 0 ? [1] : []
    content {
      gcp_public_cidrs_access_enabled = var.gcp_public_cidrs_access_enabled

      dynamic "cidr_blocks" {
        for_each = var.master_authorized_networks
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    # network_policy_config addon — only relevant when datapath_provider is not ADVANCED_DATAPATH.
    network_policy_config {
      disabled = var.datapath_provider == "ADVANCED_DATAPATH" ? true : !var.enable_network_policy
    }
  }

  # Explicit Calico network policy is mutually exclusive with Dataplane V2.
  # Dataplane V2 enforces network policy natively (no extra block needed).
  dynamic "network_policy" {
    for_each = var.datapath_provider == "ADVANCED_DATAPATH" ? [] : [1]
    content {
      enabled  = var.enable_network_policy
      provider = var.enable_network_policy ? "CALICO" : "PROVIDER_UNSPECIFIED"
    }
  }

  logging_service    = var.logging_service
  monitoring_service = var.monitoring_service

  resource_labels = var.resource_labels

  lifecycle {
    ignore_changes = [
      node_config,
      initial_node_count,
    ]
  }
}
