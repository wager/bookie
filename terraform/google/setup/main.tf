# A GCS Terraform backend.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.58.0"
    }
  }
}

provider "google" {
  project = var.google_project_id
  region  = var.google_region
  zone    = var.google_zone
}

# A GCS bucket that stores the Terraform state.
resource "google_storage_bucket" "terraform_state" {
  name = "wager-terraform"

  versioning {
    enabled = true
  }
}
