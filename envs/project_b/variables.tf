################################################################################
# Required
################################################################################
variable "org_id" { type = string }
variable "billing_account" { type = string }

################################################################################
# Region / Zone (Single zone deployment)
################################################################################

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone (single-zone deployment)"
  type        = string
  default     = "us-central1-a"
}

################################################################################
# Naming
################################################################################

variable "name_prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "commit"
}

# VPC & Subnets
variable "vpc_name" {
  type    = string
  default = "commit-vpc-b"
}

variable "subnet_gke_name" {
  type    = string
  default = "commit-gke"
}

variable "subnet_proxy_name" {
  type    = string
  default = "commit-proxy"
}

variable "subnet_psc_nat_name" {
  type    = string
  default = "commit-psc-nat"
}

# GKE
variable "gke_cluster_name" {
  type    = string
  default = "commit-gke"
}

variable "gke_node_pool_name" {
  type    = string
  default = "commit-pool"
}

variable "gke_node_sa_id" {
  type    = string
  default = "commit-gke-nodes"
}

# Optional networking (only if private nodes)
variable "router_name" {
  type    = string
  default = "commit-router"
}

variable "nat_name" {
  type    = string
  default = "commit-nat"
}

# Firewall
variable "fw_lb_health_name" {
  type    = string
  default = "commit-allow-lb-health"
}

variable "fw_internal_name" {
  type    = string
  default = "commit-allow-internal"
}

# App
variable "app_namespace" {
  type    = string
  default = "commit"
}

variable "app_name" {
  type    = string
  default = "commit-app"
}

variable "app_neg_prefix" {
  type    = string
  default = "commit-app-neg"
}

# Internal Load Balancer
variable "ilb_hc_name" {
  type    = string
  default = "commit-ilb-hc"
}

variable "ilb_bes_name" {
  type    = string
  default = "commit-ilb-bes"
}

variable "ilb_url_map_name" {
  type    = string
  default = "commit-ilb-urlmap"
}

variable "ilb_cert_name" {
  type    = string
  default = "commit-ilb-cert"
}

variable "ilb_proxy_name" {
  type    = string
  default = "commit-ilb-proxy"
}

variable "ilb_ip_name" {
  type    = string
  default = "commit-ilb-ip"
}

variable "ilb_fr_name" {
  type    = string
  default = "commit-ilb-fr"
}

# PSC
variable "psc_attachment_name" {
  type    = string
  default = "commit-psc-sa"
}

################################################################################
# Networking (CIDR)
################################################################################

variable "vpc_cidr_gke" {
  type    = string
  default = "10.20.0.0/24"
}

variable "vpc_cidr_pods" {
  type    = string
  default = "10.21.0.0/16"
}

variable "vpc_cidr_services" {
  type    = string
  default = "10.22.0.0/20"
}

variable "vpc_cidr_proxy" {
  type    = string
  default = "10.23.0.0/23"
}

variable "vpc_cidr_psc_nat" {
  type    = string
  default = "10.23.2.0/24"
}

variable "pods_range_name" {
  type    = string
  default = "pods"
}

variable "services_range_name" {
  type    = string
  default = "services"
}

################################################################################
# GKE Networking Options
################################################################################

variable "enable_private_nodes" {
  description = "If true → private nodes (requires Cloud NAT)"
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  type    = string
  default = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  description = "Optional list of allowed CIDRs to access master"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

################################################################################
# GKE Compute (Minimal / Cheap)
################################################################################

variable "gke_machine_type" {
  type    = string
  default = "e2-small"
}

variable "gke_node_count" {
  type    = number
  default = 1
}

variable "gke_use_spot" {
  description = "Use spot/preemptible nodes to reduce cost"
  type        = bool
  default     = true
}

################################################################################
# Application
################################################################################

variable "app_image" {
  type    = string
  default = "nginx:alpine"
}

variable "app_service_port" {
  type    = number
  default = 443
}

variable "app_target_port" {
  type    = number
  default = 443
}

variable "internal_lb_hostname" {
  type    = string
  default = "internal.commit.local"
}

################################################################################
# Private Service Connect (PSC)
################################################################################

variable "psc_consumer_accept_projects" {
  description = "Projects allowed to connect via PSC"
  type = list(object({
    project_id       = string
    connection_limit = number
  }))
  default = []
}

################################################################################
# Labels
################################################################################

variable "labels" {
  type = map(string)
  default = {
    managed_by = "terraform"
    app        = "commit"
  }
}