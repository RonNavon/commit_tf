variable "project_id"      { type = string }
variable "name"            { type = string }
variable "description" {
  type    = string
  default = null
}
variable "default_service" {
  type        = string
  description = "Default backend service self_link"
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
