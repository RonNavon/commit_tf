variable "project_id" { type = string }
variable "name"       { type = string }

variable "mode" {
  description = "MANAGED for Google-managed (global only) or SELF_MANAGED for BYO cert."
  type        = string
  validation {
    condition     = contains(["MANAGED", "SELF_MANAGED"], var.mode)
    error_message = "mode must be MANAGED or SELF_MANAGED."
  }
}

variable "scope" {
  type    = string
  default = "GLOBAL"
  validation {
    condition     = contains(["GLOBAL", "REGIONAL"], var.scope)
    error_message = "scope must be GLOBAL or REGIONAL."
  }
}

# Validation: Google-managed certs are global-only.
# We can't cross-validate two variables in pre-1.9 Terraform validation blocks,
# so we use a precondition in main.tf instead. (See validation in main.tf.)
variable "region" {
  type    = string
  default = null
}

variable "domains" {
  description = "List of domains for the managed certificate."
  type        = list(string)
  default     = []
}

variable "certificate_pem" {
  description = "PEM certificate body for self-managed certs. Sensitive."
  type        = string
  default     = null
  sensitive   = true
}

variable "private_key_pem" {
  description = "PEM private key for self-managed certs. Sensitive."
  type        = string
  default     = null
  sensitive   = true
}

variable "description" {
  type    = string
  default = null
}
