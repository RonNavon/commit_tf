output "id" {
  value = (
    var.mode == "MANAGED" && var.scope == "GLOBAL" ? google_compute_managed_ssl_certificate.managed[0].id :
    var.mode == "SELF_MANAGED" && var.scope == "GLOBAL" ? google_compute_ssl_certificate.self_global[0].id :
    google_compute_region_ssl_certificate.self_regional[0].id
  )
}

output "self_link" {
  value = (
    var.mode == "MANAGED" && var.scope == "GLOBAL" ? google_compute_managed_ssl_certificate.managed[0].self_link :
    var.mode == "SELF_MANAGED" && var.scope == "GLOBAL" ? google_compute_ssl_certificate.self_global[0].self_link :
    google_compute_region_ssl_certificate.self_regional[0].self_link
  )
}

output "name" {
  value = (
    var.mode == "MANAGED" && var.scope == "GLOBAL" ? google_compute_managed_ssl_certificate.managed[0].name :
    var.mode == "SELF_MANAGED" && var.scope == "GLOBAL" ? google_compute_ssl_certificate.self_global[0].name :
    google_compute_region_ssl_certificate.self_regional[0].name
  )
}
