output "id" {
  value = var.scope == "GLOBAL" ? google_compute_health_check.global[0].id : google_compute_region_health_check.regional[0].id
}

output "self_link" {
  value = var.scope == "GLOBAL" ? google_compute_health_check.global[0].self_link : google_compute_region_health_check.regional[0].self_link
}

output "name" {
  value = var.scope == "GLOBAL" ? google_compute_health_check.global[0].name : google_compute_region_health_check.regional[0].name
}
