variable "org_id" {
  description = "The organization id for the associated resource/module"
  type        = string
}

variable "parent_folder" {
  description = "The ID of the parent folder to apply the resource/module"
  type        = string
  default     = ""
}

variable "folder_name" {
  description = "Name of the folder to be created"
  type        = string
}
