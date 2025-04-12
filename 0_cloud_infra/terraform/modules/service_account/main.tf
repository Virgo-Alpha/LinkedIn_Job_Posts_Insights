resource "google_service_account" "sa" {
  project      = var.project_id
  account_id   = var.account_id
  display_name = var.display_name
}

resource "google_service_account_key" "key" {
  service_account_id = google_service_account.sa.name
}

resource "local_file" "sa_key_file" {
  content  = base64decode(google_service_account_key.key.private_key)
  filename = "${path.module}/../../../gcloud_creds/service-account.json"
  file_permission = "644"  # Restrict file permissions
}
