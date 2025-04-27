
locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"), { inputs = {} })
  org_id          = "651150601306"
}

terraform {
  source = "../../../..//terraform/stacks/kubernetes"
}

include {
  path = find_in_parent_folders("org.hcl")
}

dependency "parent" {
  config_path = "${get_terragrunt_dir()}/../"
  mock_outputs = {
    project = { project_id = "wp-live-kubernets-6662" }
  }
}

dependency "network" {
  config_path = "../vpc_network"
  mock_outputs = {
    vpc = {
      "network" = {
        "network_name" = "wp-live-kubernets-us-east1"
      }
    }
  }
}


inputs = {

  project_id   = dependency.parent.outputs.project.project_id
  network_name = "${dependency.parent.outputs.labels.resource_name}-network"
  range_pods = "gke-container-subnet"
  range_services= "gke-service-subnet"
  serviceaccountgke = "wp-kubernetes-wb3@wp-live-kubernets-6662.iam.gserviceaccount.com"

# variabile deployment cu database
    gke_credentials_secret = "cloudsql-instance-credentials-terraform"
    database = "wordpress"
}
