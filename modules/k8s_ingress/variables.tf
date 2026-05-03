variable "name"      { type = string }
variable "namespace" {
  type    = string
  default = "default"
}
variable "labels" {
  type    = map(string)
  default = {}
}
variable "annotations" {
  type    = map(string)
  default = {}
}

variable "ingress_class" {
  type    = string
  default = "gce-internal"
}

variable "pre_shared_cert_name" {
  description = "Name of pre-shared SSL cert (regional self-managed cert)."
  type        = string
}

variable "regional_static_ip_name" {
  description = "Name of regional static internal IP for the ingress."
  type        = string
}

variable "default_service_name" { type = string }
variable "default_service_port" {
  type    = number
  default = 443
}

variable "rules" {
  type = list(object({
    host = string
    paths = list(object({
      path         = string
      path_type    = optional(string, "Prefix")
      service_name = string
      service_port = number
    }))
  }))
  default = []
}
