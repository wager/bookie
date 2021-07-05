resource "google_container_node_pool" "actions" {
  name       = "actions"
  cluster    = google_container_cluster.live.name
  location   = google_container_cluster.live.location
  project    = google_container_cluster.live.project
  node_count = 3

  node_config {
    tags = ["actions"]
  }
}

resource "helm_release" "actions" {
  name             = "actions"
  namespace        = "actions"
  chart            = "actions-runner-controller"
  repository       = "https://actions-runner-controller.github.io/actions-runner-controller"
  create_namespace = true

  values = [<<-YAML
    authSecret.github_token: ${var.github_token}",
    nodeSelector:
      "cloud.google.com/gke-nodepool": ${google_container_node_pool.actions.name}
    replicaCount: 1
    YAML
  ]
}
