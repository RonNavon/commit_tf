output "id"                 { value = google_container_cluster.this.id }
output "name"               { value = google_container_cluster.this.name }
output "endpoint"           { value = google_container_cluster.this.endpoint }
output "ca_certificate"     { value = google_container_cluster.this.master_auth[0].cluster_ca_certificate }
output "self_link"          { value = google_container_cluster.this.self_link }
output "location"           { value = google_container_cluster.this.location }
output "workload_pool"      { value = "${var.project_id}.svc.id.goog" }
