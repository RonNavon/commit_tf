resource "kubernetes_service_v1" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = var.labels
    annotations = {
      "cloud.google.com/neg" = jsonencode({
        exposed_ports = {
          "443" = {
            name = "${var.neg_name_prefix}-443"
          }
        }
      })
    }
  }
  

  spec {
    type             = var.type
    selector         = var.selector
    session_affinity = var.session_affinity

    dynamic "port" {
      for_each = var.ports
      content {
        name        = port.value.name
        port        = port.value.port
        target_port = port.value.target_port
        protocol    = port.value.protocol
      }
    }
  }
}
