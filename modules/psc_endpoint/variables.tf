variable "project_id" { type = string }
variable "name"       { type = string }
variable "region"     { type = string }
variable "network"    { type = string }
variable "subnetwork" { type = string }

variable "target_service_attachment" {
  description = "Self link of the producer's service attachment."
  type        = string
}

variable "ip_address" {
  description = "Optional static internal IP. If null, auto-allocated."
  type        = string
  default     = null
}

variable "allow_psc_global_access" {
  type    = bool
  default = false
}
variable "labels" {
  type    = map(string)
  default = {}
}
