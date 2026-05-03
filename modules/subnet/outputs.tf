output "id" {
  description = "Subnet ID."
  value       = google_compute_subnetwork.this.id
}

output "self_link" {
  description = "Subnet self link."
  value       = google_compute_subnetwork.this.self_link
}

output "name" {
  description = "Subnet name."
  value       = google_compute_subnetwork.this.name
}

output "ip_cidr_range" {
  description = "Primary CIDR of the subnet."
  value       = google_compute_subnetwork.this.ip_cidr_range
}

output "secondary_ranges" {
  description = "Secondary range names attached to the subnet."
  value       = [for r in google_compute_subnetwork.this.secondary_ip_range : r.range_name]
}
