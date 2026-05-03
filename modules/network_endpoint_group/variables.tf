variable "project_id" {
  description = "Project where the NEG lives (the GKE project)."
  type        = string
}

variable "neg_name" {
  description = "Name of the zonal NEG (must match cloud.google.com/neg annotation neg_name on the K8s Service)."
  type        = string
}

variable "zones" {
  description = "List of zones where the NEG exists (one per cluster node zone)."
  type        = list(string)
}
