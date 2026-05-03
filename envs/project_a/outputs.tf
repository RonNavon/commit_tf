output "external_lb_ip" {
  description = "Reserved global static IP of the external HTTPS LB. Publish on DNS."
  value       = google_compute_global_address.elb.address
}

output "psc_endpoint_ip" {
  description = "Private IP of the PSC consumer endpoint inside Project A's VPC."
  value       = module.psc_endpoint.ip_address
}
