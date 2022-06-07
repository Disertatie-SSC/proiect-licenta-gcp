resource "google_service_account" "kubernetes-sa" {

  #checkov:skip=CKV2_GCP_3: "Ensure that there are only GCP-managed service account keys for each service account"
  project      = "wp-live-kubernets-6662"
  account_id   = "wp-kubernetes-wb3"
  display_name = "kubernets-serviceaccount"
  description  = "Terraform service account"
}

resource "google_organization_iam_member" "kubernetes_sa" {
  for_each = toset([
    "roles/compute.viewer",
    "roles/compute.securityAdmin",
    "roles/container.clusterAdmin",
    "roles/container.developer",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/resourcemanager.projectIamAdmin"
  ])
  org_id = var.org_id
  role   = each.value
  member = "serviceAccount:${google_service_account.kubernetes-sa.email}"
}