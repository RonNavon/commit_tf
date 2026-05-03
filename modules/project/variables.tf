variable "deletion_policy" {
  description = "Resource deletion policy"
  type        = string
  default     = "DELETE"
}
variable "random_project_id" {
  description = "Whether to generate a random project ID suffix"
  type        = bool
  default     = true
}
variable "org_id" { type = string }
variable "billing_account" { type = string }
variable "activate_apis" { type = list(string) }
variable "name" { type = string }

