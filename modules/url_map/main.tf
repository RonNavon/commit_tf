resource "google_compute_url_map" "global" {
  count           = var.scope == "GLOBAL" ? 1 : 0
  project         = var.project_id
  name            = var.name
  description     = var.description
  default_service = var.default_service
}

resource "google_compute_region_url_map" "regional" {
  count           = var.scope == "REGIONAL" ? 1 : 0
  project         = var.project_id
  region          = var.region
  name            = var.name
  description     = var.description
  default_service = var.default_service
}
