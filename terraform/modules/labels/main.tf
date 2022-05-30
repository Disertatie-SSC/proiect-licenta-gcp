locals {

  transformed_labels = {
    email          = replace(replace(lower(var.email), var.email_dot_character.original, var.email_dot_character.transformed), var.email_at_character.original, var.email_at_character.transformed)
    live           = replace(lower(var.live), var.transformation_regex.not_allowed, var.transformation_regex.replacement)
    environment    = replace(lower(var.environment), var.transformation_regex.not_allowed, var.transformation_regex.replacement)
    servicename    = replace(lower(var.servicename), var.transformation_regex.not_allowed, var.transformation_regex.replacement)
    subservicename = replace(lower(var.subservicename), var.transformation_regex.not_allowed, var.transformation_regex.replacement)
  }

  # If empty don't include, otherwide prefix with hyphen
  subservicename_check = local.transformed_labels.subservicename == "" ? "" : "-${local.transformed_labels.subservicename}"
  # If empty don't include, otherwide prefix with underscore
  underscore_subservicename_check = local.transformed_labels.subservicename == "" ? "" : "_${local.transformed_labels.subservicename}"

  # e.g. pd-prod-propellant or pd-prod-propellant-frontend
  resource_name = "wp-${local.transformed_labels.environment}-${local.transformed_labels.servicename}${local.subservicename_check}"

  # e.g. pd-prod-propellant-21a6 or pd-prod-propellant-frontend-21a6
  random_resource_name = "${local.resource_name}-${random_id.random.hex}"

  # e.g. pd_prod_propellant or pd_prod_propellant_frontend
  underscore_resource_name = "wp-${local.transformed_labels.environment}_${local.transformed_labels.servicename}${local.underscore_subservicename_check}"

  # e.g. pd_prod_propellant_21a6 or pd_prod_propellant_frontend_21a6
  underscore_random_resource_name = "${local.underscore_resource_name}_${random_id.random.hex}"
}

resource "random_id" "random" {
  byte_length = 2
}
