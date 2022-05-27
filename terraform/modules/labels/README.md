# Labels

This module provides a consistent set of `labels` that can be applied to GCP
resources for billing purposes. It also provides resource names backed by a
naming convention to keep your GCP resource names consistent.

## Module outputs

This module provides:

- A map of labels to use on GCP resources:

```hcl
transformed_labels = {
  "email"       = "allanλpropellantødigital"
  "costcentre"  = "014FA4-63EA7E-59DED2"
  "live"        = "no"
  "environment" = "dev"
  "servicename" = "propellant"
}
```

- Standardised resource names based on your inputs:

```hcl
resource_name                   = pd-dev-propellant
random_resource_name            = pd-dev-propellant-21a6
underscore_resource_name        = pd_dev_propellant
underscore_random_resource_name = pd_dev_propellant_21a6
```

## GCP Label restrictions

GCP labels have many restrictions on which characters you can use.

### Both label keys and values

- Maximum of 64 characters
- Allowed
  - lowercase
  - numeric
  - underscores
  - hyphens/dashes
  - international characters e.g. ç, é, ý, ú, í, ó, á
- Not allowed
  - Any other special character e.g. @, ., /, or a space

### Label values only

- No uppercase characters
- Can be empty

### Label keys only

- Keys must start with a lowercase letter
- Keys must be unique within a set of labels for a resource

### Label transformation

- Due to the restrictions that apply to GCP `labels`, this module will transform
  all inputs (e.g. making them lowercase, removing characters that are not
  allowed).

- `Email` will go through a bespoke transformation (substituting restricted
  special characters for international characters).
  - For example, `email = allan@propellant.digital` will be transformed
    into `email = allanλpropellantødigital`

- This is to ensure that labels are compliant before they are applied to a GCP
  resource.

## Naming convention

This module will output a resource name based on your inputs using the following
naming convention:

```hcl
pd-{environment}-{servicename}
pd-{environment}-{servicename}-{suffix}
pd_{environment}_{servicename}
pd_{environment}_{servicename}_{suffix}
```

Note:

- `pd` = propellant digital

Examples:

```hcl
pd-dev-propellant
pd-dev-propellant-frontend
pd-dev-propellant-21a6
pd-dev-propellant-frontend-21a6
pd_dev_propellant
pd_dev_propellant_frontend
pd_dev_propellant_21a6
pd_dev_propellant_frontend-21a6
```

## Simple example

### Input

```hcl
module "labels" {
  source      = "./labels"

  email       = "allan@propellant.digital"
  costcentre  = "014FA4-63EA7E-59DED2"
  live        = "no"
  environment = "dev"
  servicename = "propellant"
}
```

### Output

```hcl
transformed_labels = {
  "email"       = "allanλpropellantødigital"
  "costcentre"  = "014FA4-63EA7E-59DED2"
  "live"        = "no"
  "environment" = "dev"
  "servicename" = "propellant"
}
resource_name                   = pd-dev-propellant
random_resource_name            = pd-dev-propellant-21a6
underscore_resource_name        = pd_dev_propellant
underscore_random_resource_name = pd_dev_propellant_21a6
```

## How to use it with other resources

```hcl
module "labels" {
  source      = "./labels"

  email       = "allan@propellant.digital"
  costcentre  = "014FA4-63EA7E-59DED2"
  live        = "no"
  environment = "dev"
  servicename = "propellant"
}

resource "google_compute_instance" "vm" {
  name              = module.labels.random_resource_name
  boot_disk         = ...
  network_interface = ...
  labels            = module.labels.transformed_labels
}

resource "google_project" "project" {
  name       = ...
  project_id = ...
  labels     = module.labels.transformed_labels
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [random_id.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_costcentre"></a> [costcentre](#input\_costcentre) | Cost centre assigned to this GCP resource/project e.g. PD1234 | `string` | n/a | yes |
| <a name="input_email"></a> [email](#input\_email) | Contact email for this GCP resource/project e.g. propellant.digital.team@propellant.digital.com | `string` | n/a | yes |
| <a name="input_email_at_character"></a> [email\_at\_character](#input\_email\_at\_character) | Character used to transform any @ (at sign) in the email label | `map(any)` | <pre>{<br>  "original": "@",<br>  "transformed": "λ"<br>}</pre> | no |
| <a name="input_email_dot_character"></a> [email\_dot\_character](#input\_email\_dot\_character) | Character used to transform any . (dots) in the email label | `map(any)` | <pre>{<br>  "original": ".",<br>  "transformed": "ø"<br>}</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Short environment name e.g. dev, prod, sbx | `string` | n/a | yes |
| <a name="input_live"></a> [live](#input\_live) | Is this service live? Either yes OR no | `string` | n/a | yes |
| <a name="input_servicename"></a> [servicename](#input\_servicename) | Provide your service name e.g. orderbooking, paymentprocessing | `string` | n/a | yes |
| <a name="input_subservicename"></a> [subservicename](#input\_subservicename) | Optional, additional identifier for a service e.g. frontend will form {servicename}-frontend | `string` | `""` | no |
| <a name="input_transformation_regex"></a> [transformation\_regex](#input\_transformation\_regex) | Regex used to transform labels<br>  Has two keys:<br>  not\_allowed = is the regex to determine which characters should be removed, defaults to allow only lowercase, numeric, underscores, and hyphens<br>  replacement = is the character you want to replace removed characters with, defaults to empty | `map(any)` | <pre>{<br>  "not_allowed": "/[^a-z0-9-_]/",<br>  "replacement": ""<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_random_resource_name"></a> [random\_resource\_name](#output\_random\_resource\_name) | Standardised resource name with a random suffix to facilitate uniqueness |
| <a name="output_raw_labels"></a> [raw\_labels](#output\_raw\_labels) | Map of labels with no transformation |
| <a name="output_resource_name"></a> [resource\_name](#output\_resource\_name) | Standardised resource name |
| <a name="output_transformed_labels"></a> [transformed\_labels](#output\_transformed\_labels) | Map of transformed labels adhering to GCP restrictions |
| <a name="output_underscore_random_resource_name"></a> [underscore\_random\_resource\_name](#output\_underscore\_random\_resource\_name) | Standardised resource name with a random suffix to facilitate uniqueness and underscore delimiter |
| <a name="output_underscore_resource_name"></a> [underscore\_resource\_name](#output\_underscore\_resource\_name) | Standardised resource name with underscore delimiter |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
