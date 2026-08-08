resource "kubernetes_namespace" "taskflow" {
  metadata {
    name = var.app_namespace
  }
}

resource "kubernetes_service_account" "taskflow_sa" {
  metadata {
    name      = "taskflow-sa"
    namespace = kubernetes_namespace.taskflow.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.taskflow_sa.email
    }
  }
}

resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = kubernetes_namespace.taskflow.metadata[0].name
  }

  data = {
    DB_PASSWORD = google_secret_manager_secret_version.db_password.secret_data
  }
}
