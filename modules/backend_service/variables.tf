variable "project_id" { type = string }
variable "name"       { type = string }
variable "scope" {
  description = "GLOBAL for external HTTPS LB, REGIONAL for internal HTTPS LB."
  type        = string
  default     = "GLOBAL"
  validation {
    condition     = contains(["GLOBAL", "REGIONAL"], var.scope)
    error_message = "scope must be GLOBAL or REGIONAL."
  }
}
variable "region" {
  type    = string
  default = null
}

variable "description" {
  type    = string
  default = null
}

variable "protocol" {
  description = "Backend protocol. Use HTTPS for end-to-end TLS."
  type        = string
  default     = "HTTPS"
}

variable "port_name" {
  type    = string
  default = "https"
}
variable "timeout_sec" {
  type    = number
  default = 30
}

variable "load_balancing_scheme" {
  description = "EXTERNAL_MANAGED for external HTTPS LB, INTERNAL_MANAGED for internal HTTPS LB."
  type        = string
  default     = "EXTERNAL_MANAGED"
}

variable "enable_cdn" {
  type    = bool
  default = false
}

variable "health_check" {
  description = "Self link of the health check."
  type        = string
}

variable "security_policy" {
  description = "Self link of Cloud Armor security policy. Only valid for GLOBAL backend services."
  type        = string
  default     = null
}

variable "backends" {
  description = "List of backend group configs."
  type = list(object({
    group                 = string
    balancing_mode        = optional(string, "RATE")
    max_rate_per_endpoint = optional(number, 100)
    capacity_scaler       = optional(number, 1.0)
  }))
}

variable "log_enable" {
  type    = bool
  default = true
}
variable "log_sample_rate" {
  type    = number
  default = 1.0
}

variable "iap" {
  type = object({
    oauth2_client_id     = string
    oauth2_client_secret = string
  })
  default = null
}
