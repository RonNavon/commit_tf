output "gke_cluster_name" {
  value = module.gke_cluster.name
}

# output "internal_lb_ip" {
#   value = google_compute_address.ilb.address
# }

# output "service_attachment_self_link" {
#   description = "Pass this into Project A as producer_service_attachment."
#   value       = module.psc_service_attachment.self_link
# }
