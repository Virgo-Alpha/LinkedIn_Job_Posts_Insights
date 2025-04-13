output "dataset_id" {
  value = google_bigquery_dataset.dataset.dataset_id
}

output "dataset_name" {
  value = google_bigquery_dataset.dataset.friendly_name
}
