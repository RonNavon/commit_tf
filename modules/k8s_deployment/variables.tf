variable "name"      { type = string }
variable "namespace" {
  type    = string
  default = "default"
}
variable "labels" {
  type    = map(string)
  default = {}
}

variable "replicas" {
  type    = number
  default = 2
}

variable "match_labels" {
  description = "Label selector that matches both deployment template AND service selector."
  type        = map(string)
}

variable "pod_annotations" {
  type    = map(string)
  default = {}
}

variable "service_account_name" {
  type    = string
  default = null
}

variable "container_name" {
  type    = string
  default = "app"
}
variable "image"          { type = string }

variable "container_ports" {
  type = list(object({
    name           = string
    container_port = number
    protocol       = optional(string, "TCP")
  }))
  default = [{ name = "https", container_port = 8443 }]
}

variable "env" {
  type    = map(string)
  default = {}
}

variable "resources" {
  type = object({
    requests = optional(map(string), {})
    limits   = optional(map(string), {})
  })
  default = {
    requests = { cpu = "100m", memory = "128Mi" }
    limits   = { cpu = "500m", memory = "512Mi" }
  }
}

variable "readiness_probe" {
  type = object({
    path                  = string
    port                  = number
    scheme                = optional(string, "HTTPS")
    initial_delay_seconds = optional(number, 5)
    period_seconds        = optional(number, 10)
  })
  default = null
}

variable "liveness_probe" {
  type = object({
    path                  = string
    port                  = number
    scheme                = optional(string, "HTTPS")
    initial_delay_seconds = optional(number, 15)
    period_seconds        = optional(number, 20)
  })
  default = null
}

variable "volumes" {
  type = list(object({
    name            = string
    secret_name     = optional(string)
    config_map_name = optional(string)
  }))
  default = []
}

variable "volume_mounts" {
  type = list(object({
    name       = string
    mount_path = string
    read_only  = optional(bool, false)
  }))
  default = []
}
