# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

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

module "gke" {
  source                     = "github.com/terraform-google-modules/terraform-google-kubernetes-engine.git"
  project_id                 = var.project_id
  name                       = "kubernetes-wordpress-licenta"
  region                     = "us-east1"
  zones                      = ["us-east1-b", "us-east1-c"]
  network                    = var.network_name
  subnetwork                 = "wp-live-kubernets-us-east1"
  ip_range_pods              = var.range_pods
  ip_range_services          = var.range_services
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false

  node_pools = [
    {
      name                      = "default-node-pool"
      machine_type              = "e2-medium"
      node_locations            = "us-east1-b,us-east1-c"
      min_count                 = 1
      max_count                 = 10
      local_ssd_count           = 0
      disk_size_gb              = 100
      disk_type                 = "pd-standard"
      image_type                = "COS_CONTAINERD"
      enable_gcfs               = false
      auto_repair               = true
      auto_upgrade              = true
      service_account           = var.serviceaccountgke
      preemptible               = false
      initial_node_count        = 2
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}
