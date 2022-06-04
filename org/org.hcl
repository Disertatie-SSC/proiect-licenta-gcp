# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURARI TERRAGRUNT
# Terragrunt este un wrapper subtire pentru Terraform care furnizeaza uneltele necesare in lucrul cu mai multe module de terraform precum si ,
# stare detasata si blocare: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# Cum configurezi terragrunt sa stocheze automat fisierele de tip stare: https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/#create-remote-state-and-locking-resources-automatically
remote_state {
  backend = "gcs"
  # Acelasi bucket pentru toate  mediile - resursele sunt create in directorul bootstrap
  config = {
    bucket = "wordpress-live-terraform-state"
    prefix = "org/${path_relative_to_include()}/terraform.tfstate"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}

# Generam codul care permite interactioanrea cu GCP - resursele sunt create in directorul bootstrap
generate "gcp-provider" {
  path      = "providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "google" {
  alias = "impersonate"

  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

data "google_service_account_access_token" "default" {
  provider               = google.impersonate
  target_service_account = "wordpress-live-terraform@wordpress-live-terraform-cb2b.iam.gserviceaccount.com"
  scopes                 = ["userinfo-email", "cloud-platform"]
  lifetime               = "600s"
}

provider "google" {
  access_token = data.google_service_account_access_token.default.access_token
}

provider "google-beta" {
  access_token = data.google_service_account_access_token.default.access_token
}
EOF
}

# ---------------------------------------------------------------------------------------------------------------------
# PARAMETRI GLOBALI
# Aceste variable se aplica la toate configurarile sub-directoarelor. Acestea sunt lipte automate in fisierul de configurare
# copil `terragrunt.hcl` prin blocul de "include"
# ---------------------------------------------------------------------------------------------------------------------


locals {
}

# Configurati toate variabilele de baza pe care toate resursele le mostenesc. Acest lucru este util mai ales pentru configurari multiple
# unde sursele de date ale terraform_remote_state sunt plasate direct in modul
inputs = {

  services = [
    "iam.googleapis.com",
    "cloudbilling.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "containerscanning.googleapis.com",
    "storage-api.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudkms.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "appengine.googleapis.com",
    "secretmanager.googleapis.com",
    "dns.googleapis.com"
  ]

  billing_account = "01CF65-E838CD-27FD32",
  org_id          = "651150601306"

  # policy_allowed_domain_ids = [
  #   # Appsbroker Cloud Identity Customer ID
  #   "C02l4xnhr",
  #   # Client Cloud Identity Customer ID
  #   "C02yvlxje"
  # ]
}
