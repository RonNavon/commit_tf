output "name"      { value = kubernetes_ingress_v1.this.metadata[0].name }
output "namespace" { value = kubernetes_ingress_v1.this.metadata[0].namespace }
