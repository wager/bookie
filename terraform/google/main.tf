####################################################################################################
#                                           Google Cloud                                           #
####################################################################################################

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

data "google_client_config" "current" {}

####################################################################################################
#                                             Network                                              #
####################################################################################################

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

# A firewall rule that exposes tcp:* and udp:* on all boxes internally.
resource "google_compute_firewall" "allow_internal" {
  name          = "allow-internal"
  network       = google_compute_network.vpc.name
  source_ranges = ["10.128.0.0/9"]

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
}

####################################################################################################
#                                             Storage                                              #
####################################################################################################

# A GCS bucket that stores archived data.
resource "google_storage_bucket" "archive" {
  name           = "wager-archive"
  location       = var.google_region
  requester_pays = true
}

# A GCS bucket that stores the Bazel build cache.
resource "google_storage_bucket" "build" {
  name                        = "wager-build"
  location                    = var.google_region
  uniform_bucket_level_access = true

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 7
    }
  }
}

####################################################################################################
#                                             Compute                                              #
####################################################################################################

// A Kubernetes cluster.
resource "google_container_cluster" "live" {
  name                     = "live"
  initial_node_count       = 1
  location                 = var.google_region
  network                  = google_compute_network.vpc.name
  remove_default_node_pool = true

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/16"
    services_ipv4_cidr_block = "/22"
  }
}

# A Kubernetes provider.
provider "kubernetes" {
  load_config_file = false
  host             = "https://${data.google_container_cluster.live.endpoint}"
  token            = data.google_client_config.current.access_token

  cluster_ca_certificate = base64decode(
    google_container_cluster.live.master_auth[0].cluster_ca_certificate,
  )
}
