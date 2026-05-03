resource "google_compute_address" "this" {
  project      = var.project_id
  name         = "${var.name}-ip"
  region       = var.region
  subnetwork   = var.subnetwork
  address_type = "INTERNAL"
  address      = var.ip_address
}

resource "google_compute_forwarding_rule" "this" {
  project    = var.project_id
  name       = var.name
  region     = var.region
  network    = var.network
  subnetwork = var.subnetwork

  ip_address = google_compute_address.this.id

  # PSC endpoint: target = service attachment, no load_balancing_scheme.
  target                = var.target_service_attachment
  load_balancing_scheme = ""

  allow_psc_global_access = var.allow_psc_global_access
  labels                  = var.labels
}
