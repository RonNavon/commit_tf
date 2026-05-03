resource "kubernetes_deployment_v1" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = var.labels
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = var.match_labels
    }

    template {
      metadata {
        labels      = var.match_labels
        annotations = var.pod_annotations
      }

      spec {
        service_account_name = var.service_account_name

        container {
          name  = var.container_name
          image = var.image

          dynamic "port" {
            for_each = var.container_ports
            content {
              container_port = port.value.container_port
              name           = port.value.name
              protocol       = port.value.protocol
            }
          }

          dynamic "env" {
            for_each = var.env
            content {
              name  = env.key
              value = env.value
            }
          }

          resources {
            requests = var.resources.requests
            limits   = var.resources.limits
          }

          dynamic "readiness_probe" {
            for_each = var.readiness_probe == null ? [] : [var.readiness_probe]
            content {
              http_get {
                path   = readiness_probe.value.path
                port   = readiness_probe.value.port
                scheme = readiness_probe.value.scheme
              }
              initial_delay_seconds = readiness_probe.value.initial_delay_seconds
              period_seconds        = readiness_probe.value.period_seconds
            }
          }

          dynamic "liveness_probe" {
            for_each = var.liveness_probe == null ? [] : [var.liveness_probe]
            content {
              http_get {
                path   = liveness_probe.value.path
                port   = liveness_probe.value.port
                scheme = liveness_probe.value.scheme
              }
              initial_delay_seconds = liveness_probe.value.initial_delay_seconds
              period_seconds        = liveness_probe.value.period_seconds
            }
          }

          dynamic "volume_mount" {
            for_each = var.volume_mounts
            content {
              name       = volume_mount.value.name
              mount_path = volume_mount.value.mount_path
              read_only  = volume_mount.value.read_only
            }
          }
        }

        dynamic "volume" {
          for_each = var.volumes
          content {
            name = volume.value.name
            dynamic "secret" {
              for_each = volume.value.secret_name == null ? [] : [1]
              content {
                secret_name = volume.value.secret_name
              }
            }
            dynamic "config_map" {
              for_each = volume.value.config_map_name == null ? [] : [1]
              content {
                name = volume.value.config_map_name
              }
            }
          }
        }
      }
    }
  }
}
