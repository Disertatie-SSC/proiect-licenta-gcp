locals {
  project_id = "wp-live-db-f946"
}

# data "google_service_account_key" "mykey" {
#   name  = google_service_account_key.cloudsql-proxy-key.private_key
# }

resource "google_service_account" "sql-proxy" {

  #checkov:skip=CKV2_GCP_3: "Ensure that there are only GCP-managed service account keys for each service account"
  project      = var.project_id
  account_id   = "wp-live-db-f946"
  display_name = "sql-proxy"
  description  = "Sql_proxy service account"
}

resource "google_organization_iam_member" "sql_proxy" {
  for_each = toset([
    "roles/cloudsql.client",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
  ])
  org_id = "651150601306"
  role   = each.value
  member = "serviceAccount:${google_service_account.sql-proxy.email}"
}

# resource "google_service_account_key" "cloudsql-proxy-key" {
#   service_account_id = google_service_account.sql-proxy.name
# }

# resource "local_file" "key" {
#   filename = "key.json"
#   content  = "${base64decode(google_service_account_key.cloudsql-proxy-key.private_key)}"
# }