variable "labels" {
  description = <<EOF
  Map of labels (i.e. tags) to add to project for billing purposes
  Required labels example:
  labels = {
    email          = "sh4gie@gmail.com"
    costcentre     = ""
    live           = "no"
    environment    = "live"
    servicename    = "wordpress"
    subservicename = ""
  }
EOF
  type        = map(string)
}

variable "project_id_override" {
  description = "If you don't want to use the automatically generated project ID, specify an ID here, note: Project IDs must be globally unique"
  type        = string
  default     = ""
}

variable "billing_account" {
  description = "The ID of the billing account this project belongs to"
  type        = string
}

variable "org_id" {
  description = <<EOF
  The organization ID this project belongs to.
  Only one of org_id or folder_id may be specified.
  If the org_id is specified then the project is created at the top level of the org.
EOF
  type        = string
  default     = ""
}

variable "folder_id" {
  description = <<EOF
  The ID of the folder this project should be created under.
  Only one of org_id or folder_id may be specified.
  If the folder_id is specified, then the project is created under the specified folder.
EOF
  type        = string
  default     = ""
}

# Services
variable "services" {
  description = "The list of APIs to activate within the project: https://cloud.google.com/service-usage/docs/enabled-service"
  type        = list(string)
}

variable "disable_on_destroy" {
  description = "Whether project services will be disabled when the resources are destroyed. https://www.terraform.io/docs/providers/google/r/google_project_service.html#disable_on_destroy"
  default     = true
  type        = bool
}

variable "disable_dependent_services" {
  description = "Whether services that are enabled and which depend on this service should also be disabled when this service is destroyed. https://www.terraform.io/docs/providers/google/r/google_project_service.html#disable_dependent_services"
  default     = true
  type        = bool
}
