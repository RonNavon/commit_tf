variable "project_id" { type = string }
variable "name"       { type = string }

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

variable "description" {
  type    = string
  default = null
}

variable "protocol" {
  type    = string
  default = "HTTPS"
  validation {
    condition     = contains(["HTTP", "HTTPS"], var.protocol)
    error_message = "protocol must be HTTP or HTTPS."
  }
}

variable "port" {
  type    = number
  default = 443
}
variable "request_path" {
  type    = string
  default = "/healthz"
}
variable "host" {
  type    = string
  default = null
}

variable "check_interval_sec" {
  type    = number
  default = 10
}
variable "timeout_sec" {
  type    = number
  default = 5
}
variable "healthy_threshold" {
  type    = number
  default = 2
}
variable "unhealthy_threshold" {
  type    = number
  default = 3
}

variable "enable_log" {
  type    = bool
  default = true
}
