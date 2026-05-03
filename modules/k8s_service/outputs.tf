output "name"      { value = kubernetes_service_v1.this.metadata[0].name }
output "namespace" { value = kubernetes_service_v1.this.metadata[0].namespace }
output "neg_names" {
  description = "Map of port -> NEG name (matches what GKE controller will create per zone)."
  value       = { for p in var.ports : tostring(p.port) => "${var.neg_name_prefix}-${p.port}" }
}