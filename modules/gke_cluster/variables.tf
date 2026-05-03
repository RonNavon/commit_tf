variable "project_id"           { type = string }
variable "name"                 { type = string }
variable "location" {
  type        = string
  description = "Region (regional cluster) or zone."
}
variable "network"              { type = string }
variable "subnetwork"           { type = string }

variable "pods_range_name"     { type = string }
variable "services_range_name" { type = string }

variable "release_channel" {
  type    = string
  default = "REGULAR"
  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel must be RAPID, REGULAR, or STABLE."
  }
}

variable "datapath_provider" {
  type    = string
  default = "ADVANCED_DATAPATH"
}

variable "enable_private_nodes" {
  description = "If false, nodes get public IPs and don't need Cloud NAT — cheaper for demos."
  type        = bool
  default     = false
}
variable "enable_private_endpoint" {
  type    = bool
  default = false
}
variable "master_ipv4_cidr_block" {
  description = "Master CIDR — only used when enable_private_nodes = true."
  type        = string
  default     = null
}
variable "master_global_access" {
  type    = bool
  default = true
}

variable "master_authorized_networks" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "gcp_public_cidrs_access_enabled" {
  description = "Whether public Google-owned CIDRs may reach the master endpoint."
  type        = bool
  default     = false
}

variable "enable_network_policy" {
  type    = bool
  default = true
}
variable "deletion_protection" {
  type    = bool
  default = false
}

variable "logging_service" {
  type    = string
  default = "logging.googleapis.com/kubernetes"
}
variable "monitoring_service" {
  type    = string
  default = "monitoring.googleapis.com/kubernetes"
}

variable "resource_labels" {
  type    = map(string)
  default = {}
}
