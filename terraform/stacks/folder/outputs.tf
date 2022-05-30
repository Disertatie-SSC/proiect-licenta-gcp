output "folder_id" {
  description = "Folder ID"
  value       = google_folder.folder.name
}

output "folder_name" {
  description = "Folder display name"
  value       = google_folder.folder.display_name
}

output "folder_parent" {
  description = "Folder parent"
  value       = google_folder.folder.parent
}
