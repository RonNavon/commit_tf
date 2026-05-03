################################################################################
# Project B — GKE workload + Internal HTTPS LB + PSC producer.
# Single-file root config. Every value is driven from terraform.tfvars
# (or the variable defaults in variables.tf).
################################################################################

module "project" {
  source = "../../modules/project"

  name              = "project-b"
  random_project_id = true
  org_id            = var.org_id
  billing_account   = var.billing_account
  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com"
  ]
  deletion_policy = "DELETE" # For demo purposes;
}

# -----------------------------------------------------------------------------
# VPC + subnets
# -----------------------------------------------------------------------------

module "vpc" {
  source     = "../../modules/vpc"
  project_id = module.project.id
  name       = var.vpc_name
}

module "subnet_gke" {
  source        = "../../modules/subnet"
  project_id    = module.project.id
  name          = var.subnet_gke_name
  network       = module.vpc.self_link
  region        = var.region
  ip_cidr_range = var.vpc_cidr_gke

  secondary_ranges = [
    { range_name = var.pods_range_name, ip_cidr_range = var.vpc_cidr_pods },
    { range_name = var.services_range_name, ip_cidr_range = var.vpc_cidr_services },
  ]
}

module "subnet_proxy" {
  source        = "../../modules/subnet"
  project_id    = module.project.id
  name          = var.subnet_proxy_name
  network       = module.vpc.self_link
  region        = var.region
  ip_cidr_range = var.vpc_cidr_proxy
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

module "subnet_psc_nat" {
  source        = "../../modules/subnet"
  project_id    = module.project.id
  name          = var.subnet_psc_nat_name
  network       = module.vpc.self_link
  region        = var.region
  ip_cidr_range = var.vpc_cidr_psc_nat
  purpose       = "PRIVATE_SERVICE_CONNECT"
}

# -----------------------------------------------------------------------------
# Firewall rules — only what's strictly required.
# -----------------------------------------------------------------------------

module "fw_allow_lb_health" {
  source     = "../../modules/firewall_rule"
  project_id = module.project.id
  name       = var.fw_lb_health_name
  network    = module.vpc.self_link
  direction  = "INGRESS"
  priority   = 1000

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
    var.vpc_cidr_proxy,
  ]

  allow = [
    { protocol = "tcp", ports = [tostring(var.app_target_port)] },
  ]
}

module "fw_allow_internal" {
  source     = "../../modules/firewall_rule"
  project_id = module.project.id
  name       = var.fw_internal_name
  network    = module.vpc.self_link
  direction  = "INGRESS"
  priority   = 1000

  source_ranges = [
    var.vpc_cidr_gke,
    var.vpc_cidr_pods,
    var.vpc_cidr_services,
  ]

  allow = [
    { protocol = "tcp", ports = [] },
    { protocol = "udp", ports = [] },
    { protocol = "icmp", ports = [] },
  ]
}

# -----------------------------------------------------------------------------
# Service account for GKE nodes (least-privilege).
# -----------------------------------------------------------------------------

resource "google_service_account" "gke_nodes" {
  project      = module.project.id
  account_id   = var.gke_node_sa_id
  display_name = "GKE node SA (${var.name_prefix})"
}

resource "null_resource" "enable_default_sa" {
  provisioner "local-exec" {
    command = <<EOT
PROJECT_NUMBER=$(gcloud projects describe ${module.project.id} --format="value(projectNumber)")
SA="$PROJECT_NUMBER-compute@developer.gserviceaccount.com"

gcloud iam service-accounts enable "$SA" \
  --project=${module.project.id}
EOT
  }
}


resource "google_project_iam_member" "gke_nodes" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/artifactregistry.reader",
  ])
  project = module.project.id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

# -----------------------------------------------------------------------------
# GKE — zonal cluster, single small node pool.
# -----------------------------------------------------------------------------

module "gke_cluster" {
  source     = "../../modules/gke_cluster"
  project_id = module.project.id
  name       = var.gke_cluster_name
  location   = var.zone

  network    = module.vpc.self_link
  subnetwork = module.subnet_gke.self_link

  pods_range_name     = var.pods_range_name
  services_range_name = var.services_range_name

  enable_private_nodes       = var.enable_private_nodes
  master_ipv4_cidr_block     = var.master_ipv4_cidr_block
  master_authorized_networks = var.master_authorized_networks

  enable_network_policy = false
  deletion_protection   = false

  resource_labels = var.labels
}

module "gke_node_pool" {
  source       = "../../modules/gke_node_pool"
  project_id   = module.project.id
  name         = var.gke_node_pool_name
  cluster_name = module.gke_cluster.name
  location     = module.gke_cluster.location

  service_account = google_service_account.gke_nodes.email

  machine_type = var.gke_machine_type
  node_count   = var.gke_node_count
  spot         = var.gke_use_spot

  autoscaling = { enabled = false }

  labels = { workload = "app" }
  tags   = ["${var.name_prefix}-gke"]
}

# -----------------------------------------------------------------------------
# Workload — single nginx container terminating TLS on :443.
# -----------------------------------------------------------------------------

resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = var.app_namespace
  }

  depends_on = [module.gke_node_pool]
}

# Single self-signed cert reused by both the pod and the Internal LB.
resource "tls_private_key" "tls" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "tls" {
  private_key_pem = tls_private_key.tls.private_key_pem

  subject {
    common_name = var.internal_lb_hostname
  }

  validity_period_hours = 24 * 365
  early_renewal_hours   = 24 * 30

  allowed_uses = ["key_encipherment", "digital_signature", "server_auth"]

  dns_names = [
    var.internal_lb_hostname,
    var.app_name,
    "${var.app_name}.${var.app_namespace}.svc.cluster.local",
  ]
}

resource "kubernetes_secret_v1" "pod_tls" {
  metadata {
    name      = "${var.app_name}-tls"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_self_signed_cert.tls.cert_pem
    "tls.key" = tls_private_key.tls.private_key_pem
  }
}

resource "kubernetes_config_map_v1" "nginx" {
  metadata {
    name      = "${var.app_name}-nginx"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  data = {
    "default.conf" = <<-EOT
      server {
        listen ${var.app_target_port} ssl;
        ssl_certificate     /etc/tls/tls.crt;
        ssl_certificate_key /etc/tls/tls.key;

        location /healthz {
          access_log off;
          return 200 "ok\n";
        }

        location / {
          default_type text/plain;
          return 200 "Hello, World!\n";
        }
      }
    EOT
  }
}

resource "kubernetes_deployment_v1" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace_v1.app.metadata[0].name
    labels    = { app = var.app_name }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = var.app_name }
    }

    template {
      metadata {
        labels = { app = var.app_name }
      }

      spec {
        container {
          name  = "nginx"
          image = var.app_image

          port {
            name           = "https"
            container_port = var.app_target_port
            protocol       = "TCP"
          }

          volume_mount {
            name       = "tls"
            mount_path = "/etc/tls"
            read_only  = true
          }

          volume_mount {
            name       = "nginx-conf"
            mount_path = "/etc/nginx/conf.d"
            read_only  = true
          }

          resources {
            requests = { cpu = "20m", memory = "32Mi" }
            limits   = { cpu = "100m", memory = "128Mi" }
          }

          readiness_probe {
            http_get {
              path   = "/healthz"
              port   = var.app_target_port
              scheme = "HTTPS"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }

        volume {
          name = "tls"
          secret {
            secret_name = kubernetes_secret_v1.pod_tls.metadata[0].name
          }
        }

        volume {
          name = "nginx-conf"
          config_map {
            name = kubernetes_config_map_v1.nginx.metadata[0].name
          }
        }
      }
    }
  }
}

module "app_service" {
  source    = "../../modules/k8s_service"
  name      = var.app_name
  namespace = kubernetes_namespace_v1.app.metadata[0].name
  selector  = { app = var.app_name }

  ports = [{
    name        = "https"
    port        = var.app_service_port
    target_port = var.app_target_port
  }]

  enable_neg      = true
  neg_name_prefix = var.app_neg_prefix

  depends_on = [kubernetes_deployment_v1.app]
}

# -----------------------------------------------------------------------------
# Internal HTTPS Load Balancer (regional, INTERNAL_MANAGED, HTTPS-only).
# -----------------------------------------------------------------------------

module "ilb_health_check" {
  source       = "../../modules/health_check"
  project_id   = module.project.id
  name         = var.ilb_hc_name
  scope        = "REGIONAL"
  region       = var.region
  protocol     = "HTTPS"
  port         = var.app_target_port
  request_path = "/healthz"
}

module "ilb_neg" {
  source     = "../../modules/network_endpoint_group"
  project_id = module.project.id
  neg_name   = "${var.app_neg_prefix}-${var.app_service_port}"
  zones      = [var.zone]

  depends_on = [module.app_service]
}

module "ilb_backend_service" {
  source     = "../../modules/backend_service"
  project_id = module.project.id
  name       = var.ilb_bes_name
  scope      = "REGIONAL"
  region     = var.region

  protocol              = "HTTPS"
  port_name             = "https"
  load_balancing_scheme = "INTERNAL_MANAGED"

  health_check = module.ilb_health_check.self_link

  backends = [
    {
      group                 = "projects/${module.project.id}/regions/${var.region}/networkEndpointGroups/${var.app_neg_prefix}-${var.app_service_port}"
      balancing_mode        = "RATE"
      max_rate_per_endpoint = 1000
      capacity_scaler       = 1.0
    }
  ]
}

module "ilb_url_map" {
  source          = "../../modules/url_map"
  project_id      = module.project.id
  name            = var.ilb_url_map_name
  scope           = "REGIONAL"
  region          = var.region
  default_service = module.ilb_backend_service.self_link
}

module "ilb_ssl_cert" {
  source     = "../../modules/ssl_certificate"
  project_id = module.project.id
  name       = var.ilb_cert_name
  mode       = "SELF_MANAGED"
  scope      = "REGIONAL"
  region     = var.region

  certificate_pem = tls_self_signed_cert.tls.cert_pem
  private_key_pem = tls_private_key.tls.private_key_pem
}

module "ilb_target_proxy" {
  source     = "../../modules/target_https_proxy"
  project_id = module.project.id
  name       = var.ilb_proxy_name
  scope      = "REGIONAL"
  region     = var.region

  url_map          = module.ilb_url_map.self_link
  ssl_certificates = [module.ilb_ssl_cert.self_link]
}

resource "google_compute_address" "ilb" {
  project      = module.project.id
  name         = var.ilb_ip_name
  region       = var.region
  subnetwork   = module.subnet_gke.self_link
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
}

module "ilb_forwarding_rule" {
  source     = "../../modules/forwarding_rule"
  project_id = module.project.id
  name       = var.ilb_fr_name
  scope      = "REGIONAL"
  region     = var.region

  target                = module.ilb_target_proxy.self_link
  port_range            = "443"
  load_balancing_scheme = "INTERNAL_MANAGED"

  network    = module.vpc.self_link
  subnetwork = module.subnet_gke.self_link
  ip_address = google_compute_address.ilb.self_link

  depends_on = [module.subnet_proxy]
}

# -----------------------------------------------------------------------------
# PSC producer — service attachment publishing the internal forwarding rule.
# -----------------------------------------------------------------------------

module "psc_service_attachment" {
  source     = "../../modules/psc_service_attachment"
  project_id = module.project.id
  name       = var.psc_attachment_name
  region     = var.region

  target_service = module.ilb_forwarding_rule.self_link
  nat_subnets    = [module.subnet_psc_nat.self_link]

  connection_preference = length(var.psc_consumer_accept_projects) > 0 ? "ACCEPT_MANUAL" : "ACCEPT_AUTOMATIC"
  consumer_accept_lists = var.psc_consumer_accept_projects

  reconcile_connections = true
}
