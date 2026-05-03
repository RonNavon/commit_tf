resource "kubernetes_ingress_v1" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = var.labels
    annotations = merge({
      "kubernetes.io/ingress.class"                  = var.ingress_class
      "kubernetes.io/ingress.allow-http"             = "false"
      "ingress.gcp.kubernetes.io/pre-shared-cert"    = var.pre_shared_cert_name
      "kubernetes.io/ingress.regional-static-ip-name" = var.regional_static_ip_name
    }, var.annotations)
  }

  spec {
    default_backend {
      service {
        name = var.default_service_name
        port {
          number = var.default_service_port
        }
      }
    }

    dynamic "rule" {
      for_each = var.rules
      content {
        host = rule.value.host
        http {
          dynamic "path" {
            for_each = rule.value.paths
            content {
              path      = path.value.path
              path_type = path.value.path_type
              backend {
                service {
                  name = path.value.service_name
                  port {
                    number = path.value.service_port
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
