# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"), { inputs = {} })

}

terraform {
  source = "../../../..//terraform/stacks/vpc_network"
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

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  org_id = "651150601306"
  project_id   = dependency.parent.outputs.project.project_id
  network_name = "${dependency.parent.outputs.labels.resource_name}-network"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name               = "${dependency.parent.outputs.labels.resource_name}-us-east1"
      subnet_ip                 = "10.156.30.128/25"
      subnet_region             = "us-east1"
      subnet_private_access     = "true"
      subnet_flow_logs          = "true"
      subnet_flow_logs_interval = "INTERVAL_10_MIN"
      subnet_flow_logs_sampling = 0.5
      subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
    },
  ]

  secondary_ranges = {
     "${dependency.parent.outputs.labels.resource_name}-us-east1" = [
            {
                range_name    = "gke-container-subnet"
                ip_cidr_range = "10.96.0.0/14"
            },
             {
                range_name    = "gke-service-subnet"
                ip_cidr_range = "10.100.0.0/20"
            },
        ]
    }

  routes           = []

  firewall_rules = [{
    name                    = "allow-ssh-ingress"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["22"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  },
  {
    name                    = "allow-icmp-ingress"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [{
      protocol = "icmp"
      ports    = []
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }
  
  
  ]
}
