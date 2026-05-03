resource "google_compute_service_attachment" "this" {
  project  = var.project_id
  region   = var.region
  name     = var.name

  description = var.description

  enable_proxy_protocol = var.enable_proxy_protocol
  connection_preference = var.connection_preference

  # The internal LB forwarding rule that the attachment publishes.
  target_service = var.target_service

  # NAT subnets used to translate consumer connections.
  nat_subnets = var.nat_subnets

  reconcile_connections = var.reconcile_connections

  dynamic "consumer_accept_lists" {
    for_each = var.consumer_accept_lists
    content {
      project_id_or_num = consumer_accept_lists.value.project_id
      connection_limit  = consumer_accept_lists.value.connection_limit
    }
  }

  consumer_reject_lists = var.consumer_reject_lists
}
