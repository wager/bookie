####################################################################################################
#                                           Google Cloud                                           #
####################################################################################################

terraform {
  backend "gcs" {
    bucket = "wager-terraform"
    prefix = "platform"
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }

    google = {
      source  = "hashicorp/google"
      version = "~> 3.81.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.2.0"
    }
  }
}

provider "google" {
  project = var.google_project_id
  region  = var.google_region
  zone    = var.google_zone
}

data "google_client_config" "current" {}

# Enable Google Cloud Storage.
resource "google_project_service" "cloud_storage" {
  service = "storage-component.googleapis.com"
}

# Enable the Google Compute Engine.
resource "google_project_service" "compute_engine" {
  service = "compute.googleapis.com"
}

# Enable the Google Kubernetes Engine.
resource "google_project_service" "kubernetes_engine" {
  service = "container.googleapis.com"
}

####################################################################################################
#                                             Identity                                             #
####################################################################################################

# A service account that runs GitHub Actions on Google Kubernetes Engine.
resource "google_service_account" "github" {
  account_id   = "github"
  display_name = "GitHub"
  description  = "Runs continuous integration and delivery workflows on GitHub."
}

resource "google_service_account_key" "github" {
  service_account_id = google_service_account.github.name
}

provider "github" {
  owner = "wager"
  token = var.github_token
}

resource "github_actions_organization_secret" "gcp_service_account_key" {
  secret_name     = "GCP_SERVICE_ACCOUNT_KEY"
  visibility      = "private"
  plaintext_value = google_service_account_key.github.private_key
}

# A service account that launches virtual machines on Google Compute Engine.
resource "google_service_account" "bookie" {
  account_id   = "bookie"
  display_name = "Bookie"
  description  = "Manages the Wager development platform."
}

####################################################################################################
#                                             Network                                              #
####################################################################################################

# A virtual private cloud.
resource "google_compute_network" "vpc" {
  name = "vpc"
}

# A firewall rule that exposes tcp:22 on all boxes for SSH.
resource "google_compute_firewall" "allow_ssh" {
  name          = "allow-ssh"
  network       = google_compute_network.vpc.name
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# A firewall rule that exposes tcp:* and udp:* on all boxes for internal communication.
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

# A bucket that stores archived data.
resource "google_storage_bucket" "archive" {
  name     = "wager-archive"
  location = var.google_region
}

resource "google_storage_bucket_iam_binding" "archive_storage_object_admin" {
  bucket = google_storage_bucket.archive.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.bookie.email}",
  ]
}

# A bucket that stores the Bazel build cache.
resource "google_storage_bucket" "build" {
  name                        = "wager-build"
  location                    = var.google_region
  force_destroy               = true
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

resource "google_storage_bucket_iam_binding" "build_storage_object_admin" {
  bucket = google_storage_bucket.build.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.github.email}",
  ]
}

# A bucket that stores the Wager cache.
resource "google_storage_bucket" "cache" {
  name          = "wager-cache"
  location      = var.google_region
  force_destroy = true
}

resource "google_storage_bucket_iam_binding" "cache_storage_object_admin" {
  bucket = google_storage_bucket.cache.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.bookie.email}",
  ]
}

####################################################################################################
#                                             Compute                                              #
####################################################################################################

# A Kubernetes cluster.
resource "google_container_cluster" "live" {
  name                     = "live"
  location                 = var.google_zone
  network                  = google_compute_network.vpc.name
  initial_node_count       = 1
  remove_default_node_pool = true

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/16"
    services_ipv4_cidr_block = "/22"
  }
}

# A Helm provider.
provider "helm" {
  kubernetes {
    host  = "https://${google_container_cluster.live.endpoint}"
    token = data.google_client_config.current.access_token

    cluster_ca_certificate = base64decode(
      google_container_cluster.live.master_auth[0].cluster_ca_certificate,
    )
  }
}

# A Spark cluster.
resource "google_container_node_pool" "spark" {
  name       = "spark"
  cluster    = google_container_cluster.live.name
  location   = google_container_cluster.live.location
  project    = google_container_cluster.live.project
  node_count = 3

  node_config {
    tags = ["spark"]
  }
}

resource "helm_release" "spark" {
  name             = "spark"
  version          = "5.7.2"
  chart            = "spark"
  repository       = "https://charts.bitnami.com/bitnami"
  cleanup_on_fail  = true
  create_namespace = true

  values = [<<-YAML
    image:
      repository: wager/runtime
      tag: latest
      pullPolicy: Always
    nodeSelector:
      "cloud.google.com/gke-nodepool": ${google_container_node_pool.spark.name}
    worker:
      autoscaling:
        enabled: true
        replicasMax: 2
    YAML
  ]
}
