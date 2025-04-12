resource "random_id" "suffix" {
  byte_length = 4
}

resource "google_project" "project" {
  name            = var.project_name
  project_id      = "${var.project_name}-${random_id.suffix.hex}"
  # org_id          = var.org_id
  billing_account = var.billing_account_id
}
