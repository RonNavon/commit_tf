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

variable "type" {
  type    = string
  default = "ClusterIP"
}

variable "selector" { type = map(string) }

variable "session_affinity" {
  type    = string
  default = "None"
}

variable "ports" {
  type = list(object({
    name        = string
    port        = number
    target_port = any
    protocol    = optional(string, "TCP")
  }))
}

variable "enable_neg" {
  description = "Whether to add cloud.google.com/neg annotation for Container-Native LB."
  type        = bool
  default     = true
}

variable "neg_name_prefix" {
  description = "Prefix for NEG names. The actual NEG names will be <prefix>-<port>."
  type        = string
  default     = "neg"
}
