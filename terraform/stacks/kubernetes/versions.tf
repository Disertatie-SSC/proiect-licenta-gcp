terraform {
  required_version = ">=0.13"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.10.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
  }
  provider_meta "google" {
    module_name = "blueprints/terraform/terraform-google-kubernetes-engine/v21.1.0"
  }
}