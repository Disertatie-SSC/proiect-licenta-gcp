variable "project_id" {
  description = "The ID of the project where this VPC will be created"
}

variable "network_name" {
  description = "The name of the network being created"
}

variable "firewall_rules" {
  type        = any
  description = "List of firewall rules"
  default     = []
}

variable "routing_mode" {
  type        = string
  default     = "GLOBAL"
  description = "The network routing mode (default 'GLOBAL')"
}

variable "mtu" {
  type        = number
  description = "The network MTU. Must be a value between 1460 and 1500 inclusive. If set to 0 (meaning MTU is unset), the network will default to 1460 automatically."
  default     = 0
}

variable "delete_default_internet_gateway_routes" {
  type        = bool
  description = "If set, ensure that all routes within the network specified whose names begin with 'default-route' and with a next hop of 'default-internet-gateway' are deleted"
  default     = false
}

variable "subnets" {
  type        = list(map(string))
  description = <<EOF
  "The list of subnets being created"
  Usage example:
  subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = "us-west1"
        },
        {
            subnet_name           = "subnet-02"
            subnet_ip             = "10.10.20.0/24"
            subnet_region         = "us-west1"
            subnet_private_access = "true"
            subnet_flow_logs      = "true"
            description           = "This subnet has a description"
        },
        {
            subnet_name               = "subnet-03"
            subnet_ip                 = "10.10.30.0/24"
            subnet_region             = "us-west1"
            subnet_flow_logs          = "true"
            subnet_flow_logs_interval = "INTERVAL_10_MIN"
            subnet_flow_logs_sampling = 0.7
            subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
        }
    ]
EOF
}

variable "secondary_ranges" {
  type        = map(list(object({ range_name = string, ip_cidr_range = string })))
  description = <<EOF
  "Secondary ranges that will be used in some of the subnets"
  Usage example:
  secondary_ranges = {
        subnet-01 = [
            {
                range_name    = "subnet-01-secondary-01"
                ip_cidr_range = "192.168.64.0/24"
            },
        ]

        subnet-02 = []
    }
EOF
}


variable "routes" {
  type        = list(map(string))
  description = <<EOF
  "List of routes being created in this VPC"
  Usage example:
  routes     = [
        {
            name                   = "egress-internet"
            description            = "route through IGW to access internet"
            destination_range      = "0.0.0.0/0"
            tags                   = "egress-inet"
            next_hop_internet      = "true"
        },
        {
            name                   = "app-proxy"
            description            = "route through proxy to reach app"
            destination_range      = "10.50.10.0/24"
            tags                   = "app-proxy"
            next_hop_instance      = "app-proxy-instance"
            next_hop_instance_zone = "us-west1-a"
        },
    ]
EOF
}
