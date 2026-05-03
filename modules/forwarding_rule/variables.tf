variable "project_id" { type = string }
variable "name"       { type = string }
variable "target" {
  type        = string
  description = "Self link of target proxy or service attachment for PSC consumer."
}

variable "scope" {
  type    = string
  default = "GLOBAL"
  validation {
    condition     = contains(["GLOBAL", "REGIONAL"], var.scope)
    error_message = "scope must be GLOBAL or REGIONAL."
  }
}
variable "region" {
  type    = string
  default = null
}

variable "port_range" {
  type    = string
  default = "443"
}
variable "ip_protocol" {
  type    = string
  default = "TCP"
}

variable "load_balancing_scheme" {
  description = "EXTERNAL_MANAGED for external HTTPS LB, INTERNAL_MANAGED for internal HTTPS LB, blank for PSC endpoint."
  type        = string
  default     = "EXTERNAL_MANAGED"
}

variable "ip_address" {
  type    = string
  default = null
}
variable "network" {
  type    = string
  default = null
}
variable "subnetwork" {
  type    = string
  default = null
}

variable "allow_global_access" {
  type    = bool
  default = false
}
variable "labels" {
  type    = map(string)
  default = {}
}
