output "id" {
  value = var.scope == "GLOBAL" ? google_compute_url_map.global[0].id : google_compute_region_url_map.regional[0].id
}

output "self_link" {
  value = var.scope == "GLOBAL" ? google_compute_url_map.global[0].self_link : google_compute_region_url_map.regional[0].self_link
}
