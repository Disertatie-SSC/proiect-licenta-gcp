# Required
variable "email" {
  description = "Contact email for this GCP resource/project e.g. propellant.digital.team@propellant.digital.com"
  type        = string
}

# variable "costcentre" {
#   description = "Cost centre assigned to this GCP resource/project e.g. PD1234"
#   type        = string
# }

variable "live" {
  description = "Is this service live? Either yes OR no"
  type        = string
}

variable "environment" {
  description = "Short environment name e.g. dev, prod, sbx"
  type        = string
}

variable "servicename" {
  description = "Provide your service name e.g. orderbooking, paymentprocessing"
  type        = string
}

variable "subservicename" {
  description = "Optional, additional identifier for a service e.g. frontend will form {servicename}-frontend"
  type        = string
  default     = ""
}

# String transformation defaults
variable "transformation_regex" {
  description = <<EOF
  Regex used to transform labels
  Has two keys:
  not_allowed = is the regex to determine which characters should be removed, defaults to allow only lowercase, numeric, underscores, and hyphens
  replacement = is the character you want to replace removed characters with, defaults to empty
EOF
  type        = map(any)
  default = {
    not_allowed = "/[^a-z0-9-_]/"
    replacement = ""
  }
}

variable "email_dot_character" {
  description = "Character used to transform any . (dots) in the email label"
  type        = map(any)
  default = {
    original    = "."
    transformed = "ø"
  }
}

variable "email_at_character" {
  description = "Character used to transform any @ (at sign) in the email label"
  type        = map(any)
  default = {
    original    = "@"
    transformed = "λ"
  }
}
