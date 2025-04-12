output "project_id" {
  value = google_project.project.project_id
}

output "service_account_email" {
  value = module.service_account.email
}

output "project_console_url" {
  value = "https://console.cloud.google.com/home/dashboard?project=${google_project.project.project_id}"
}

output "bucket_name" {
  value = module.storage.bucket_name
}

output "bucket_id" {
  value = module.storage.bucket_id
}

