data "google_client_config" "default" {}

# Setup SQL Database
module "db_sql_postgres" {
  source               = "github.com/terraform-google-modules/terraform-google-sql-db//modules/postgresql?ref=v8.0.0"
  project_id           = var.project_id
  additional_users     = var.additional_users
  additional_databases = var.additional_databases
  database_flags       = var.database_flags
  database_version     = var.database_version
  db_name              = var.db_name
  db_charset           = var.db_charset
  db_collation         = var.db_collation
  deletion_protection  = var.deletion_protection
  disk_autoresize      = var.disk_autoresize
  disk_size            = var.disk_size
  disk_type            = var.disk_type
  enable_default_db    = var.enable_default_db
  enable_default_user  = var.enable_default_user
  iam_user_emails      = var.iam_user_emails
  ip_configuration     = var.ip_configuration
  name                 = var.name
  region               = var.region
  tier                 = var.tier
  user_name            = var.user_name
  zone                 = var.zone
}

#Cream un service account pt sql-proxy

module "sql-proxy-sa" {
  source = "../../modules/sa_mysql"

  project_id = var.project_id
}