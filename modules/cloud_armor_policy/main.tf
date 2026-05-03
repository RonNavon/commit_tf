resource "google_compute_security_policy" "this" {
  project     = var.project_id
  name        = var.name
  description = var.description
  type        = var.type

  dynamic "adaptive_protection_config" {
    for_each = var.enable_adaptive_protection ? [1] : []
    content {
      layer_7_ddos_defense_config {
        enable = true
      }
    }
  }

  # Default rule (priority 2147483647) - evaluated last.
  rule {
    action      = var.default_action
    priority    = 2147483647
    description = "Default rule"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }

  # Custom rules
  dynamic "rule" {
    for_each = var.custom_rules
    content {
      action      = rule.value.action
      priority    = rule.value.priority
      description = rule.value.description

      dynamic "match" {
        for_each = rule.value.expression != null ? [1] : []
        content {
          expr {
            expression = rule.value.expression
          }
        }
      }

      dynamic "match" {
        for_each = rule.value.src_ip_ranges != null ? [1] : []
        content {
          versioned_expr = "SRC_IPS_V1"
          config {
            src_ip_ranges = rule.value.src_ip_ranges
          }
        }
      }
    }
  }

  # Pre-configured WAF rule sets (OWASP, etc.)
  dynamic "rule" {
    for_each = var.preconfigured_waf_rules
    content {
      action   = rule.value.action
      priority = rule.value.priority
      description = "WAF: ${rule.value.expression_id}"
      match {
        expr {
          expression = "evaluatePreconfiguredExpr('${rule.value.expression_id}')"
        }
      }
    }
  }
}
