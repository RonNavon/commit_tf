data "google_compute_network_endpoint_group" "this" {
  for_each = toset(var.zones)
  project  = var.project_id
  name     = var.neg_name
  zone     = each.value
}
