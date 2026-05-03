module "project" {
  source = "terraform-google-modules/project-factory/google"

  name              = var.name
  random_project_id = var.random_project_id
  org_id            = var.org_id
  billing_account   = var.billing_account
  activate_apis     = var.activate_apis
  deletion_policy   = var.deletion_policy # For demo purposes;
}