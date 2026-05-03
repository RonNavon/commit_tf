output "self_links" {
  description = "List of NEG self_links across all zones."
  value       = [for z, neg in data.google_compute_network_endpoint_group.this : neg.self_link]
}

output "ids" {
  description = "Map of zone -> NEG id."
  value       = { for z, neg in data.google_compute_network_endpoint_group.this : z => neg.id }
}
