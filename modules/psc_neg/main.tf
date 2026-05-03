################################################################################
# Regional NEG of type PRIVATE_SERVICE_CONNECT.
# Used as the backend of an EXTERNAL HTTPS Load Balancer to forward traffic to
# a service attachment in another VPC / project, traversing PSC.
################################################################################

resource "google_compute_region_network_endpoint_group" "this" {
  project               = var.project_id
  name                  = var.name
  region                = var.region
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"

  psc_target_service = var.psc_target_service

  network    = var.network
  subnetwork = var.subnetwork
}
