output "id"          { value = google_compute_forwarding_rule.this.id }
output "self_link"   { value = google_compute_forwarding_rule.this.self_link }
output "name"        { value = google_compute_forwarding_rule.this.name }
output "ip_address"  { value = google_compute_address.this.address }
output "psc_status"  { value = google_compute_forwarding_rule.this.psc_connection_status }
