# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"), { inputs = {} })
  org_id          = "651150601306"
}

terraform {
  source = "../../../..//terraform/stacks/kubernetes"
}

# Include all settings from the root terragrunt.hcl file
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

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  project_id   = dependency.parent.outputs.project.project_id
  network_name = "${dependency.parent.outputs.labels.resource_name}-network"
  range_pods = "gke-container-subnet"
  range_services= "gke-service-subnet"
  serviceaccountgke = "wp-kubernetes-wb3@wp-live-kubernets-6662.iam.gserviceaccount.com"
}
