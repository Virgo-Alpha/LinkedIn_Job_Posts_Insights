resource "google_storage_bucket" "bucket" {
  name     = "${var.project_name}-${var.suffix}"
  location = "US"
  project  = var.project_id
}
