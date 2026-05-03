variable "project_id" { type = string }
variable "name"       { type = string }
variable "region"     { type = string }

variable "description" {
  type    = string
  default = null
}

variable "target_service" {
  description = "Self link of the regional internal LB forwarding rule to publish."
  type        = string
}

variable "nat_subnets" {
  description = "List of self_links of subnets with purpose=PRIVATE_SERVICE_CONNECT."
  type        = list(string)
}

variable "connection_preference" {
  type    = string
  default = "ACCEPT_AUTOMATIC"
  validation {
    condition     = contains(["ACCEPT_AUTOMATIC", "ACCEPT_MANUAL"], var.connection_preference)
    error_message = "connection_preference must be ACCEPT_AUTOMATIC or ACCEPT_MANUAL."
  }
}

variable "enable_proxy_protocol" {
  type    = bool
  default = false
}
variable "reconcile_connections" {
  type    = bool
  default = true
}

variable "consumer_accept_lists" {
  description = "List of consumer projects that may auto-connect."
  type = list(object({
    project_id       = string
    connection_limit = number
  }))
  default = []
}

variable "consumer_reject_lists" {
  type    = list(string)
  default = []
}
