output "id" {
  value = local.use_global ? google_compute_backend_service.global[0].id : google_compute_region_backend_service.regional[0].id
}

output "self_link" {
  value = local.use_global ? google_compute_backend_service.global[0].self_link : google_compute_region_backend_service.regional[0].self_link
}

output "name" {
  value = local.use_global ? google_compute_backend_service.global[0].name : google_compute_region_backend_service.regional[0].name
}
