variable "project_id"  { type = string }
variable "name"        { type = string }
variable "description" {
  type    = string
  default = "Cloud Armor security policy"
}

variable "type" {
  description = "CLOUD_ARMOR or CLOUD_ARMOR_EDGE."
  type        = string
  default     = "CLOUD_ARMOR"
}

variable "default_action" {
  description = "Default action for traffic not matching any rule."
  type        = string
  default     = "allow"
}

variable "enable_adaptive_protection" {
  type    = bool
  default = true
}

variable "custom_rules" {
  description = "Custom rules. Provide either expression OR src_ip_ranges (not both)."
  type = list(object({
    priority      = number
    action        = string
    description   = optional(string)
    expression    = optional(string)
    src_ip_ranges = optional(list(string))
  }))
  default = []
}

variable "preconfigured_waf_rules" {
  description = "Pre-configured WAF expressions (e.g. xss-v33-stable, sqli-v33-stable)."
  type = list(object({
    priority      = number
    action        = string
    expression_id = string
  }))
  default = []
}
