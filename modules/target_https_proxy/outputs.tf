output "id" {
  value = var.scope == "GLOBAL" ? google_compute_target_https_proxy.global[0].id : google_compute_region_target_https_proxy.regional[0].id
}

output "self_link" {
  value = var.scope == "GLOBAL" ? google_compute_target_https_proxy.global[0].self_link : google_compute_region_target_https_proxy.regional[0].self_link
}
