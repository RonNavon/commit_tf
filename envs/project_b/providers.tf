provider "google" {
  project = "project-91f32db5-49cf-4bcf-b89"
  region  = "us-central1"
  zone    = "us-central1-c"
}

# Pull a fresh access token for the kubernetes provider so we can authenticate
# against the GKE control plane. Requires the executor to have container.developer
# (or higher) on the cluster.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_cluster.ca_certificate)
}
