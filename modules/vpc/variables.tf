variable "project_id" {
  description = "GCP project ID where the VPC will be created."
  type        = string
}

variable "name" {
  description = "Name of the VPC network."
  type        = string
}

variable "description" {
  description = "Optional description for the VPC."
  type        = string
  default     = "Custom-mode VPC managed by Terraform"
}

variable "routing_mode" {
  description = "Network-wide routing mode (REGIONAL or GLOBAL)."
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.routing_mode)
    error_message = "routing_mode must be REGIONAL or GLOBAL."
  }
}

variable "mtu" {
  description = "VPC MTU. Allowed values: 1300-8896."
  type        = number
  default     = 1460
}

variable "delete_default_routes_on_create" {
  description = "Whether to delete the default 0.0.0.0/0 route at creation."
  type        = bool
  default     = false
}
