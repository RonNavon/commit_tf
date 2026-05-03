variable "project_id"        { type = string }
variable "name"              { type = string }
variable "url_map"           { type = string }
variable "ssl_certificates"  { type = list(string) }
variable "ssl_policy" {
  type    = string
  default = null
}
variable "quic_override" {
  type    = string
  default = "NONE"
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
