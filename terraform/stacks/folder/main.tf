locals {
  parent = var.parent_folder != "" ? var.parent_folder : "organizations/${var.org_id}"
}

resource "google_folder" "folder" {
  display_name = var.folder_name
  parent       = local.parent
}
