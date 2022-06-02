module "vpc" {
  source                                 = "github.com/terraform-google-modules/terraform-google-network?ref=v3.4.0"
  auto_create_subnetworks                = false
  shared_vpc_host                        = false
  delete_default_internet_gateway_routes = var.delete_default_internet_gateway_routes

  project_id   = var.project_id
  network_name = var.network_name
  routing_mode = var.routing_mode

  subnets          = var.subnets
  secondary_ranges = var.secondary_ranges
  routes           = var.routes
  mtu              = var.mtu

  firewall_rules = var.firewall_rules
}

