variable "project_id" { type = string }
variable "name"       { type = string }
variable "region"     { type = string }

variable "psc_target_service" {
  description = "Self link of the PSC service attachment to forward traffic to."
  type        = string
}

variable "network" {
  type    = string
  default = null
}
variable "subnetwork" {
  type    = string
  default = null
}
