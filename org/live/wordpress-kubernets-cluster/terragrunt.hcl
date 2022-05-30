# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"), { inputs = {} })
  #Configurare care permite sa utilizam git tag ca si sistem de versionare
  git_tag     = "v1.0.23"
}

terraform {
  source = "../../..//terraform/stacks/project/"
}

# Includem toate setarile din fisierul de baza terragrunt.hcl din /org
include {
  path = find_in_parent_folders("org.hcl")
}

dependency "parent" {
  config_path = "${get_terragrunt_dir()}/../"
  mock_outputs = {
    folder_id = "mock"
  }
}


# Acestea sunt variable care trebuie sa parsam pentru a putea folosi modulul speficicat in configuratia de terragrunt de mai sus
inputs = merge(
  local.common_vars.inputs,
  {
    org_id    = ""
    folder_id = dependency.parent.outputs.folder_id

    labels = {
      email          = "andrei.platon@infoifr-licenta.net"
      live           = "no"
      environment    = "live"
      servicename    = "kubernets"
      subservicename = ""
    }

    email          = "andrei.platon@infoifr-licenta.net"
    live           = "no"
    environment    = "live"
    servicename    = "kubernets"
    subservicename = ""

  }
)

