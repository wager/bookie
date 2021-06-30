# A platform built on Google Cloud.
terraform {
  backend "gcs" {
    bucket = "wager-terraform"
    prefix = "platform"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.74.0"
    }
  }
}

provider "google" {
  project = var.google_project_id
  region  = var.google_region
  zone    = var.google_zone
}

# A virtual private cloud.
resource "google_compute_network" "vpc" {
  name = "vpc"
}

# A firewall rule that exposes tcp:22 on Vagrant boxes for SSH.
resource "google_compute_firewall" "allow_ssh" {
  name          = "allow-ssh"
  network       = google_compute_network.vpc.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["vagrant"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# A firewall rule that exposes tcp:8888 on Vagrant boxes for Jupyter.
resource "google_compute_firewall" "allow_jupyter" {
  name          = "allow-jupyter"
  network       = google_compute_network.vpc.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["vagrant"]

  allow {
    protocol = "tcp"
    ports    = ["8888"]
  }
}
