# Folders

Creates a GCP organization folder.

## List of resources created

- [`google_folder`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_folder)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.84.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.84.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_folder.folder](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_folder_name"></a> [folder\_name](#input\_folder\_name) | Name of the folder to be created | `string` | n/a | yes |
| <a name="input_org_id"></a> [org\_id](#input\_org\_id) | The organization id for the associated resource/module | `string` | n/a | yes |
| <a name="input_parent_folder"></a> [parent\_folder](#input\_parent\_folder) | The ID of the parent folder to apply the resource/module | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_folder_id"></a> [folder\_id](#output\_folder\_id) | Folder ID |
| <a name="output_folder_name"></a> [folder\_name](#output\_folder\_name) | Folder display name |
| <a name="output_folder_parent"></a> [folder\_parent](#output\_folder\_parent) | Folder parent |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
