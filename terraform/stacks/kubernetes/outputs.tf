output "gke" {
  description = "GKE creation outputs"
  sensitive = true
  value       = module.gke
}