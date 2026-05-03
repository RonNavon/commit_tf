################################################################################
# Project A — Cloud Armor + External HTTPS LB + PSC consumer.
# Single-file root config. Every value is driven from terraform.tfvars
# (or the variable defaults in variables.tf).
################################################################################

module "project" {
  source = "../../modules/project"

  name              = "project-a"
  random_project_id = true
  org_id            = var.org_id
  billing_account   = var.billing_account
  activate_apis = [
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
  deletion_policy = "DELETE" # For demo purposes;
}

# -----------------------------------------------------------------------------
# VPC + subnet — only needed to host the PSC NEG and PSC consumer endpoint.
# -----------------------------------------------------------------------------

module "vpc" {
  source     = "../../modules/vpc"
  project_id = module.project.id
  name       = var.vpc_name
}

module "subnet_psc_consumer" {
  source        = "../../modules/subnet"
  project_id    = module.project.id
  name          = var.subnet_psc_name
  network       = module.vpc.self_link
  region        = var.region
  ip_cidr_range = var.vpc_cidr_psc_consumer
}

module "fw_allow_psc_internal" {
  source        = "../../modules/firewall_rule"
  project_id    = module.project.id
  name          = var.fw_psc_internal_name
  network       = module.vpc.self_link
  direction     = "INGRESS"
  source_ranges = [var.vpc_cidr_psc_consumer]

  allow = [
    { protocol = "tcp", ports = ["443"] },
  ]
}

# -----------------------------------------------------------------------------
# PSC consumer endpoint — private IP forwarding to Project B's service attachment.
# -----------------------------------------------------------------------------

module "psc_endpoint" {
  source     = "../../modules/psc_endpoint"
  project_id = module.project.id
  name       = var.psc_endpoint_name
  region     = var.region

  network    = module.vpc.self_link
  subnetwork = module.subnet_psc_consumer.self_link

  target_service_attachment = var.producer_service_attachment

  allow_psc_global_access = false
  labels                  = var.labels
}

# -----------------------------------------------------------------------------
# Cloud Armor — minimal (default allow + adaptive protection).
# -----------------------------------------------------------------------------

module "cloud_armor" {
  source     = "../../modules/cloud_armor_policy"
  project_id = module.project.id
  name       = var.armor_name

  default_action             = "allow"
  enable_adaptive_protection = true
}

# -----------------------------------------------------------------------------
# External HTTPS Load Balancer (HTTPS-only, port 443).
# -----------------------------------------------------------------------------

# 1. PSC NEG — bridges the global LB into the producer VPC.
module "elb_backend_neg" {
  source     = "../../modules/psc_neg"
  project_id = module.project.id
  name       = var.psc_neg_name
  region     = var.region

  psc_target_service = var.producer_service_attachment

  network    = module.vpc.self_link
  subnetwork = module.subnet_psc_consumer.self_link
}

# 2. Health check (HTTPS, global).
module "elb_health_check" {
  source     = "../../modules/health_check"
  project_id = module.project.id
  name       = var.elb_hc_name
  scope      = "GLOBAL"
  protocol   = "HTTPS"
  port       = 443

  request_path = "/healthz"
}

# 3. Backend service with Cloud Armor attached.
module "elb_backend_service" {
  source     = "../../modules/backend_service"
  project_id = module.project.id
  name       = var.elb_bes_name
  scope      = "GLOBAL"

  protocol              = "HTTPS"
  port_name             = "https"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  health_check    = module.elb_health_check.self_link
  security_policy = module.cloud_armor.self_link

  backends = [{
    group                 = module.elb_backend_neg.self_link
    balancing_mode        = "RATE"
    max_rate_per_endpoint = 5000
    capacity_scaler       = 1.0
  }]
}

# 4. URL map.
module "elb_url_map" {
  source          = "../../modules/url_map"
  project_id      = module.project.id
  name            = var.elb_url_map_name
  scope           = "GLOBAL"
  default_service = module.elb_backend_service.self_link
}

# 5. Google-managed SSL certificate.
module "elb_ssl_cert" {
  source     = "../../modules/ssl_certificate"
  project_id = module.project.id
  name       = var.elb_cert_name
  mode       = "MANAGED"
  scope      = "GLOBAL"
  domains    = var.external_lb_domains
}

# 6. HTTPS target proxy.
module "elb_target_proxy" {
  source     = "../../modules/target_https_proxy"
  project_id = module.project.id
  name       = var.elb_proxy_name
  scope      = "GLOBAL"

  url_map          = module.elb_url_map.self_link
  ssl_certificates = [module.elb_ssl_cert.self_link]
}

# 7. Reserved global static IP for DNS publication.
resource "google_compute_global_address" "elb" {
  project = module.project.id
  name    = var.elb_ip_name
}

# 8. HTTPS-only forwarding rule on 443.
module "elb_forwarding_rule" {
  source     = "../../modules/forwarding_rule"
  project_id = module.project.id
  name       = var.elb_fr_name
  scope      = "GLOBAL"

  target                = module.elb_target_proxy.self_link
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.elb.id
}
