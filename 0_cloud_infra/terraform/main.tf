provider "google" {
  credentials = file("~/.config/gcloud/application_default_credentials.json")
  region      = "us-central1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "google_project" "project" {
  name            = var.project_name
  project_id      = "${var.project_name}-${random_id.suffix.hex}"
  billing_account = var.billing_account_id
}

module "apis" {
  source     = "./modules/apis"
  project_id = google_project.project.project_id
}

module "service_account" {
  source       = "./modules/service_account"
  project_id   = google_project.project.project_id
  account_id   = "${var.project_name}-sa"
  display_name = "${var.project_name} Service Account"
}

module "iam" {
  source                = "./modules/iam"
  project_id            = google_project.project.project_id
  service_account_email = module.service_account.email
}

# TODO: Partition the below before applying
# module "bigquery" {
#   source     = "./modules/bigquery"
#   project_id = google_project.project.project_id
#   dataset_id = "linkedin_dataset"
# }

module "storage" {
  source       = "./modules/storage"
  project_id   = google_project.project.project_id
  project_name = var.project_name
  suffix       = random_id.suffix.hex
}

