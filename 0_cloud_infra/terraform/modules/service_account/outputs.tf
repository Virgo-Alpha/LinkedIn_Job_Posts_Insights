output "email" {
  value = google_service_account.sa.email
}

# Add output to show where the file was saved
output "service_account_key_path" {
  value = local_file.sa_key_file.filename
  sensitive = true
}