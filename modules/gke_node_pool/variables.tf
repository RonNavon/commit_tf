variable "project_id"   { type = string }
variable "name"         { type = string }
variable "cluster_name" { type = string }
variable "location"     { type = string }

variable "node_count" {
  type    = number
  default = 1
}

variable "autoscaling" {
  type = object({
    enabled         = bool
    min_node_count  = optional(number, 1)
    max_node_count  = optional(number, 2)
    location_policy = optional(string, "BALANCED")
  })
  default = { enabled = false }
}

variable "auto_repair" {
  type    = bool
  default = true
}
variable "auto_upgrade" {
  type    = bool
  default = true
}

variable "upgrade_strategy" {
  type    = string
  default = "SURGE"
}
variable "max_surge" {
  type    = number
  default = 1
}
variable "max_unavailable" {
  type    = number
  default = 0
}

variable "machine_type" {
  type    = string
  default = "e2-small"
}
variable "disk_size_gb" {
  type    = number
  default = 20
}
variable "disk_type" {
  type    = string
  default = "pd-standard"
}
variable "image_type" {
  type    = string
  default = "COS_CONTAINERD"
}

variable "service_account" {
  description = "Service account email used by nodes. Should be a least-privilege SA, NOT the default."
  type        = string
}

variable "oauth_scopes" {
  type    = list(string)
  default = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "labels" {
  type    = map(string)
  default = {}
}
variable "tags" {
  type    = list(string)
  default = []
}

variable "preemptible" {
  type    = bool
  default = false
}
variable "spot" {
  description = "Use Spot VMs for nodes — substantially cheaper, demo-grade durability."
  type        = bool
  default     = true
}

variable "metadata" {
  type    = map(string)
  default = {}
}
