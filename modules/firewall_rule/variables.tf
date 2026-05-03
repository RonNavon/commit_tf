variable "project_id" { type = string }
variable "name"       { type = string }
variable "network"    { type = string }

variable "direction" {
  type    = string
  default = "INGRESS"
  validation {
    condition     = contains(["INGRESS", "EGRESS"], var.direction)
    error_message = "direction must be INGRESS or EGRESS."
  }
}

variable "priority" {
  type    = number
  default = 1000
}
variable "description" {
  type    = string
  default = null
}
variable "source_ranges" {
  type    = list(string)
  default = []
}
variable "destination_ranges" {
  type    = list(string)
  default = []
}
variable "source_tags" {
  type    = list(string)
  default = null
}
variable "target_tags" {
  type    = list(string)
  default = null
}
variable "source_service_accounts" {
  type    = list(string)
  default = null
}
variable "target_service_accounts" {
  type    = list(string)
  default = null
}
variable "disabled" {
  type    = bool
  default = false
}

variable "allow" {
  description = "List of allow rules."
  type = list(object({
    protocol = string
    ports    = optional(list(string))
  }))
  default = []
}

variable "deny" {
  description = "List of deny rules."
  type = list(object({
    protocol = string
    ports    = optional(list(string))
  }))
  default = []
}

variable "enable_logging" {
  type    = bool
  default = false
}
variable "log_metadata" {
  type    = string
  default = "INCLUDE_ALL_METADATA"
}
