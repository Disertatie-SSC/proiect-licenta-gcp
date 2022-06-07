# Terragrunt va copia configurarile terrafrom specificate de parametri sursa , impreuna cu fisierele din
# folderul de lucru, intr-un folder temporar  si executa comenzile terraform in folder-ul creat.
locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"), { inputs = {} })
  org_id          = "651150601306"
}

terraform {
  source = "../../../..//terraform/stacks/db_mysql"
}

# Includem toate setarile din fisierul de baza terragrunt.hcl din /org
include {
  path = find_in_parent_folders("org.hcl")
}

dependency "parent" {
  config_path = "${get_terragrunt_dir()}/../"
  mock_outputs = {
    project = {
      project_id = "mock"
    }
  }
}


# Acestea sunt variable care trebuie sa parsam pentru a putea folosi modulul speficicat in configuratia de terragrunt de mai sus
inputs = merge(
  local.common_vars.inputs,
  {
    project_id = dependency.parent.outputs.project.project_id

    labels = {
      email          = local.common_vars.inputs.email
      live           = local.common_vars.inputs.live
      environment    = local.common_vars.inputs.environment
      servicename    = local.common_vars.inputs.servicename
      subservicename = "sql-db"
    }

    name          = "mysql-db"
    region        = "us-east1"
    tier          = "db-n1-standard-1"
    user_name     = "wordpress"
    user_password = "InfoIfrBacau"
    zone          = "us-east1-b"

    database_version    = "MYSQL_8_0"
    db_name             = "wordpress"
    # db_charset          = "UTF8"
    # db_db_collation     = "en_US.UTF8"
    disk_autoresize     = "true"
    disk_size           = "100"
    disk_type           = "PD_SSD"
    enable_default_db   = "false"
    enable_default_user = "true"
    deletion_protection = "false"
    iam_user_emails     = ["andrei.platon@infoifr-licenta.net"]

    # ip_configuration = {
    #   authorized_networks = [
    #     {
    #       name  = "looker-host"
    #       value = "35.204.222.110"
    #     }
    #   ],
    #   ipv4_enabled    = true,
    #   private_network = null,
    #   require_ssl     = null
    # }

    # database_flags = [
    #   {
    #     name  = "cloudsql.iam_authentication"
    #     value = "on"
    #   }
    # ]
  }
)
