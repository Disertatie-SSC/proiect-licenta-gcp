output "kubernetes-sa" {
  description = "GKE service account"
  value       = google_service_account.kubernetes-sa.account_id
}