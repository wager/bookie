####################################################################################################
#                                        Google Cloud Setup                                        #
####################################################################################################

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.75.0"
    }
  }
}

provider "google" {
  project = var.google_project_id
  region  = var.google_region
  zone    = var.google_zone
}

####################################################################################################
#                                             Storage                                              #
####################################################################################################

# A bucket that stores the Terraform state.
resource "google_storage_bucket" "terraform_state" {
  name                        = "wager-terraform"
  location                    = var.google_region
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}
