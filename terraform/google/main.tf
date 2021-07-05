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
      version = "~> 3.74.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.1.0"
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

# Enable the Google Cloud Storage service.
resource "google_project_service" "cloud_storage" {
  service            = "storage-component.googleapis.com"
  disable_on_destroy = true
}

# Enable the Google Compute Engine service.
resource "google_project_service" "compute_engine" {
  service            = "compute.googleapis.com"
  disable_on_destroy = true
}

# Enable the Google Kubernetes Engine service.
resource "google_project_service" "kubernetes_engine" {
  service            = "container.googleapis.com"
  disable_on_destroy = true
}

####################################################################################################
#                                             Identity                                             #
####################################################################################################

# A service account that runs GitHub Actions on Google Kubernetes Engine.
resource "google_service_account" "github" {
  account_id   = "github"
  display_name = "Runs continuous integration and delivery workflows on GitHub."
}

resource "google_service_account_key" "github" {
  service_account_id = google_service_account.github.name
}

# A service account that launches virtual machines on Google Compute Engine.
resource "google_service_account" "vagrant" {
  account_id   = "vagrant"
  display_name = "Manages development environments using Vagrant."
}

# All Google Compute Engine instance administrators.
resource "google_project_iam_binding" "compute_instance_admin" {
  role = "roles/compute.instanceAdmin.v1"

  members = [
    "serviceAccount:${google_service_account.vagrant.email}",
  ]
}

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

# A bucket that stores archived data.
resource "google_storage_bucket" "archive" {
  name           = "wager-archive"
  location       = var.google_region
  requester_pays = true
}

resource "google_storage_bucket_iam_binding" "archive_storage_object_creator" {
  bucket = google_storage_bucket.archive.name
  role   = "roles/storage.objectCreator"
  members = [
    "serviceAccount:${google_service_account.vagrant.email}",
  ]
}

resource "google_storage_bucket_iam_binding" "archive_storage_object_viewer" {
  bucket = google_storage_bucket.archive.name
  role   = "roles/storage.objectViewer"
  members = [
    "allUsers"
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
    "serviceAccount:${google_service_account.vagrant.email}",
  ]
}

####################################################################################################
#                                             Compute                                              #
####################################################################################################

// A Kubernetes cluster.
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

# A Kubernetes provider.
provider "kubernetes" {
  host  = "https://${google_container_cluster.live.endpoint}"
  token = data.google_client_config.current.access_token

  cluster_ca_certificate = base64decode(
    google_container_cluster.live.master_auth[0].cluster_ca_certificate,
  )
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

# A certificate manager.
resource "google_container_node_pool" "cert_manager" {
  name       = "cert-manager"
  cluster    = google_container_cluster.live.name
  location   = google_container_cluster.live.location
  project    = google_container_cluster.live.project
  node_count = 1

  node_config {
    tags = ["cert-manager"]
  }
}

resource "helm_release" "cert_manager" {
  name             = google_container_node_pool.cert_manager.name
  version          = "v1.4.0"
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  cleanup_on_fail  = true
  create_namespace = true
  wait             = true

  values = [<<-YAML
    installCRDs: true
    nodeSelector:
      "cloud.google.com/gke-nodepool": ${google_container_node_pool.cert_manager.name}
    YAML
  ]
}

# A GitHub Actions runner.
provider "github" {
  owner = "wager"
  token = var.github_token
}

resource "kubernetes_secret" "github_token" {
  metadata {
    name = "github-token"
  }

  data = {
    github_token = var.github_token
  }
}

resource "github_actions_secret" "github_token" {
  repository      = "bookie"
  secret_name     = "PERSONAL_ACCESS_TOKEN"
  plaintext_value = var.github_token
}

resource "github_actions_secret" "docker_password" {
  repository      = "bookie"
  secret_name     = "DOCKER_PASSWORD"
  plaintext_value = var.docker_password
}

resource "github_actions_secret" "gcp_service_account_key" {
  repository      = "wager"
  secret_name     = "GCP_SERVICE_ACCOUNT_KEY"
  plaintext_value = google_service_account_key.github.private_key
}

resource "google_container_node_pool" "github_actions" {
  name       = "github-actions"
  cluster    = google_container_cluster.live.name
  location   = google_container_cluster.live.location
  project    = google_container_cluster.live.project
  node_count = 3

  node_config {
    tags = ["github-actions"]
  }
}

resource "helm_release" "github_actions" {
  name             = google_container_node_pool.github_actions.name
  version          = "0.12.7"
  chart            = "actions-runner-controller"
  repository       = "https://actions-runner-controller.github.io/actions-runner-controller"
  cleanup_on_fail  = true
  create_namespace = true
  depends_on       = [helm_release.cert_manager]
  wait             = true

  values = [<<-YAML
    authSecret:
      github_token: ${var.github_token}
      name: ${kubernetes_secret.github_token.metadata[0].name}
    nameOverride: github-actions
    nodeSelector:
      "cloud.google.com/gke-nodepool": ${google_container_node_pool.github_actions.name}
    YAML
  ]
}

# A Spark cluster.
resource "google_container_node_pool" "apache_spark" {
  name       = "apache-spark"
  cluster    = google_container_cluster.live.name
  location   = google_container_cluster.live.location
  project    = google_container_cluster.live.project
  node_count = 4

  node_config {
    tags = ["apache-spark"]
  }
}

resource "helm_release" "apache_spark" {
  name             = "apache-spark"
  version          = "5.6.1"
  chart            = "spark"
  repository       = "https://charts.bitnami.com/bitnami"
  cleanup_on_fail  = true
  create_namespace = true
  timeout          = 600
  wait             = true

  values = [<<-YAML
    image:
      repository: wager/runtime
      tag: latest
      pullPolicy: Always
    nodeSelector:
      "cloud.google.com/gke-nodepool": ${google_container_node_pool.apache_spark.name}
    worker:
      autoscaling:
        enabled: true
        replicasMax: 3
    YAML
  ]
}
