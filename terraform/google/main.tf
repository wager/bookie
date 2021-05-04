# A platform built on Google Cloud.
terraform {
  backend "gcs" {
    bucket = "wager-terraform"
    prefix = "platform"
  }

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

data "google_client_config" "current" {}

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

# A firewall rule that exposes tcp:3000 on Vagrant boxes for Docsify.
resource "google_compute_firewall" "allow_docsify" {
  name          = "allow-docsify"
  network       = google_compute_network.vpc.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["vagrant"]

  allow {
    protocol = "tcp"
    ports    = ["3000"]
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

// A Kubernetes cluster.
resource "google_container_cluster" "kubernetes" {
  name                     = "kubernetes"
  initial_node_count       = 1
  location                 = var.google_region
  network                  = google_compute_network.vpc.name
  remove_default_node_pool = true

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/16"
    services_ipv4_cidr_block = "/22"
  }
}

# A node pool for Spark.
resource "google_container_node_pool" "spark" {
  name       = "spark"
  cluster    = google_container_cluster.kubernetes.name
  location   = google_container_cluster.kubernetes.location
  project    = google_container_cluster.kubernetes.project
  node_count = 3

  node_config {
    tags = ["spark"]
  }
}

# A kubernetes provider.
provider "kubernetes" {
  load_config_file = false
  host             = "https://${data.google_container_cluster.kubernetes.endpoint}"
  token            = data.google_client_config.current.access_token

  cluster_ca_certificate = base64decode(
    google_container_cluster.kubernetes.master_auth[0].cluster_ca_certificate,
  )
}

# A Spark master.
resource "kubernetes_deployment" "spark_master" {
  metadata {
    name      = "master"
    namespace = "spark"
  }

  spec {
    replicas = 1

    template {
      metadata {
        labels = {
          app = "spark-master"
        }
      }

      spec {
        container {
          name    = ""
          command = ["/opt/spark/sbin/start-master.sh"]
          image   = "wager/runtime"

          resources {
            limits = {
              cpu    = "4"
              memory = "4G"
            }
          }
        }

        node_selector = {
          "cloud.google.com/gke-nodepool" = google_container_node_pool.spark.name
        }
      }
    }
  }
}

resource "kubernetes_service" "spark_master" {
  spec {
    selector = {
      app = kubernetes_deployment.spark_master.spec.0.template.0.metadata.0.labels.app
    }
  }
}

# A Spark worker.
resource "kubernetes_deployment" "spark_worker" {
  metadata {
    name      = "worker"
    namespace = "spark"
  }

  spec {
    replicas = 3

    template {
      metadata {
        labels = {
          app = "spark-worker"
        }
      }

      spec {
        container {
          name    = ""
          command = ["/opt/spark/sbin/start-slave.sh", ""]
          image   = "wager/runtime"

          resources {
            limits = {
              cpu    = "4"
              memory = "4G"
            }
          }
        }

        node_selector = {
          "cloud.google.com/gke-nodepool" = google_container_node_pool.spark.name
        }
      }
    }
  }
}

resource "kubernetes_service" "spark_worker" {
  spec {
    selector = {
      app = kubernetes_deployment.spark_worker.spec.0.template.0.metadata.0.labels.app
    }
  }
}
