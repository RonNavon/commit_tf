variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "name" {
  description = "Subnet name."
  type        = string
}

variable "network" {
  description = "VPC self_link or ID this subnet belongs to."
  type        = string
}

variable "region" {
  description = "Region for the subnet."
  type        = string
}

variable "ip_cidr_range" {
  description = "Primary CIDR range. Leave empty when purpose requires no primary range."
  type        = string
  default     = null
}

variable "description" {
  description = "Optional subnet description."
  type        = string
  default     = null
}

variable "purpose" {
  description = "Subnet purpose. Use REGIONAL_MANAGED_PROXY for proxy-only, PRIVATE_SERVICE_CONNECT for PSC NAT, otherwise null."
  type        = string
  default     = null
}

variable "role" {
  description = "Role required for proxy-only subnets (ACTIVE / BACKUP)."
  type        = string
  default     = null
}

variable "private_ip_google_access" {
  description = "Enable Private Google Access on this subnet."
  type        = bool
  default     = true
}

variable "stack_type" {
  description = "IP stack type (IPV4_ONLY or IPV4_IPV6)."
  type        = string
  default     = "IPV4_ONLY"
}

variable "secondary_ranges" {
  description = "Secondary ranges to attach (e.g. pods, services)."
  type = list(object({
    range_name    = string
    ip_cidr_range = string
  }))
  default = []
}

variable "enable_flow_logs" {
  description = "Whether to enable VPC flow logs."
  type        = bool
  default     = false
}

variable "flow_logs_aggregation_interval" {
  description = "Flow logs aggregation interval."
  type        = string
  default     = "INTERVAL_5_SEC"
}

variable "flow_logs_sampling" {
  description = "Flow logs sample rate (0.0 - 1.0)."
  type        = number
  default     = 0.5
}

variable "flow_logs_metadata" {
  description = "Flow logs metadata setting."
  type        = string
  default     = "INCLUDE_ALL_METADATA"
}
