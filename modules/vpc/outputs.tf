output "id" {
  description = "Fully qualified VPC resource ID."
  value       = google_compute_network.this.id
}

output "self_link" {
  description = "Self link of the VPC."
  value       = google_compute_network.this.self_link
}

output "name" {
  description = "Name of the VPC."
  value       = google_compute_network.this.name
}
