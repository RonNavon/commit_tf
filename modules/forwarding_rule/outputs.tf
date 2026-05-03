output "id" {
  value = local.is_global ? google_compute_global_forwarding_rule.global[0].id : google_compute_forwarding_rule.regional[0].id
}

output "self_link" {
  value = local.is_global ? google_compute_global_forwarding_rule.global[0].self_link : google_compute_forwarding_rule.regional[0].self_link
}

output "ip_address" {
  value = local.is_global ? google_compute_global_forwarding_rule.global[0].ip_address : google_compute_forwarding_rule.regional[0].ip_address
}

output "name" {
  value = local.is_global ? google_compute_global_forwarding_rule.global[0].name : google_compute_forwarding_rule.regional[0].name
}
