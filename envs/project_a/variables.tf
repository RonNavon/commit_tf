################################################################################
# Required
################################################################################
variable "org_id" { type = string }
variable "billing_account" { type = string }

variable "external_lb_domains" {
  description = "FQDNs for Google-managed SSL certificate and URL map"
  type        = list(string)
}

variable "producer_service_attachment" {
  description = "Self link of PSC service attachment from Project B"
  type        = string
}

################################################################################
# Region (must match Project B)
################################################################################

variable "region" {
  description = "GCP region (must match producer project)"
  type        = string
  default     = "us-central1"
}

################################################################################
# Naming
################################################################################

variable "name_prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "commit"
}

# VPC & Subnet
variable "vpc_name" {
  type    = string
  default = "commit-vpc-a"
}

variable "subnet_psc_name" {
  type    = string
  default = "commit-psc-consumer"
}

# Firewall
variable "fw_psc_internal_name" {
  type    = string
  default = "commit-allow-psc-internal"
}

# PSC
variable "psc_endpoint_name" {
  type    = string
  default = "commit-psc-endpoint"
}

variable "psc_neg_name" {
  type    = string
  default = "commit-elb-psc-neg"
}

# Cloud Armor
variable "armor_name" {
  type    = string
  default = "commit-armor"
}

# External Load Balancer
variable "elb_hc_name" {
  type    = string
  default = "commit-elb-hc"
}

variable "elb_bes_name" {
  type    = string
  default = "commit-elb-bes"
}

variable "elb_url_map_name" {
  type    = string
  default = "commit-elb-urlmap"
}

variable "elb_cert_name" {
  type    = string
  default = "commit-elb-cert"
}

variable "elb_proxy_name" {
  type    = string
  default = "commit-elb-proxy"
}

variable "elb_ip_name" {
  type    = string
  default = "commit-elb-ip"
}

variable "elb_fr_name" {
  type    = string
  default = "commit-elb-fr"
}

################################################################################
# Networking
################################################################################

variable "vpc_cidr_psc_consumer" {
  description = "CIDR range for PSC consumer subnet"
  type        = string
  default     = "10.10.0.0/28"
}

################################################################################
# Cloud Armor (Minimal Configuration)
################################################################################

variable "blocked_country_codes" {
  description = "Optional list of country codes to block"
  type        = list(string)
  default     = []
}

variable "rate_limit_threshold_count" {
  description = "Rate limit threshold (requests per minute)"
  type        = number
  default     = 600
}

################################################################################
# Labels
################################################################################

variable "labels" {
  description = "Common labels applied to all resources"
  type        = map(string)
  default = {
    managed_by = "terraform"
    app        = "commit"
  }
}