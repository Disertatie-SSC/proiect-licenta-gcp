# VPC Network

This modules makes it easy to set up a new VPC Network in GCP by defining your
network and subnet ranges in a concise syntax.

It supports creating:

- A Google Virtual Private Network (VPC)
- Subnets within the VPC
- Secondary ranges for the subnets (if applicable)
- Additional custom routes (if applicable)

## Further reading

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0.8 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 3.88.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 3.88.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | github.com/terraform-google-modules/terraform-google-network | v3.4.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_delete_default_internet_gateway_routes"></a> [delete\_default\_internet\_gateway\_routes](#input\_delete\_default\_internet\_gateway\_routes) | If set, ensure that all routes within the network specified whose names begin with 'default-route' and with a next hop of 'default-internet-gateway' are deleted | `bool` | `false` | no |
| <a name="input_mtu"></a> [mtu](#input\_mtu) | The network MTU. Must be a value between 1460 and 1500 inclusive. If set to 0 (meaning MTU is unset), the network will default to 1460 automatically. | `number` | `0` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | The name of the network being created | `any` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project where this VPC will be created | `any` | n/a | yes |
| <a name="input_routes"></a> [routes](#input\_routes) | "List of routes being created in this VPC"<br>  Usage example:<br>  routes     = [<br>        {<br>            name                   = "egress-internet"<br>            description            = "route through IGW to access internet"<br>            destination\_range      = "0.0.0.0/0"<br>            tags                   = "egress-inet"<br>            next\_hop\_internet      = "true"<br>        },<br>        {<br>            name                   = "app-proxy"<br>            description            = "route through proxy to reach app"<br>            destination\_range      = "10.50.10.0/24"<br>            tags                   = "app-proxy"<br>            next\_hop\_instance      = "app-proxy-instance"<br>            next\_hop\_instance\_zone = "us-west1-a"<br>        },<br>    ] | `list(map(string))` | n/a | yes |
| <a name="input_routing_mode"></a> [routing\_mode](#input\_routing\_mode) | The network routing mode (default 'GLOBAL') | `string` | `"GLOBAL"` | no |
| <a name="input_secondary_ranges"></a> [secondary\_ranges](#input\_secondary\_ranges) | "Secondary ranges that will be used in some of the subnets"<br>  Usage example:<br>  secondary\_ranges = {<br>        subnet-01 = [<br>            {<br>                range\_name    = "subnet-01-secondary-01"<br>                ip\_cidr\_range = "192.168.64.0/24"<br>            },<br>        ]<br><br>        subnet-02 = []<br>    } | `map(list(object({ range_name = string, ip_cidr_range = string })))` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | "The list of subnets being created"<br>  Usage example:<br>  subnets = [<br>        {<br>            subnet\_name           = "subnet-01"<br>            subnet\_ip             = "10.10.10.0/24"<br>            subnet\_region         = "us-west1"<br>        },<br>        {<br>            subnet\_name           = "subnet-02"<br>            subnet\_ip             = "10.10.20.0/24"<br>            subnet\_region         = "us-west1"<br>            subnet\_private\_access = "true"<br>            subnet\_flow\_logs      = "true"<br>            description           = "This subnet has a description"<br>        },<br>        {<br>            subnet\_name               = "subnet-03"<br>            subnet\_ip                 = "10.10.30.0/24"<br>            subnet\_region             = "us-west1"<br>            subnet\_flow\_logs          = "true"<br>            subnet\_flow\_logs\_interval = "INTERVAL\_10\_MIN"<br>            subnet\_flow\_logs\_sampling = 0.7<br>            subnet\_flow\_logs\_metadata = "INCLUDE\_ALL\_METADATA"<br>        }<br>    ] | `list(map(string))` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc"></a> [vpc](#output\_vpc) | VPC creation outputs |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
