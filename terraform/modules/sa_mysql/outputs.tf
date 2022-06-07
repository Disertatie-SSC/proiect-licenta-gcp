output "sql-proxy" {
  description = "GKE service account"
  value       = google_service_account.sql-proxy.account_id
}

output "cloudsql-proxy-key" {
  description = "GKE service account"
  value       = google_service_account.sql-proxy.name
}

# output "my_private_key" {
#   value = data.google_service_account_key.mykey.private_key
# }