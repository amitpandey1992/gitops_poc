output "gke_endpoint" {
  description = "GKE Cluster Endpoint"
  value       = data.google_container_cluster.primary.endpoint
}

output "argocd_namespace" {
  description = "ArgoCD Namespace"
  value       = helm_release.argocd.namespace
}

output "cloud_sql_connection_name" {
  description = "Cloud SQL Connection Name"
  value       = google_sql_database_instance.default.connection_name
}

output "wif_provider_name" {
  description = "WIF Provider Resource Name for GitHub Actions"
  value       = google_iam_workload_identity_pool_provider.github_taskflow.name
}

output "service_account_email" {
  description = "Service Account Email"
  value       = google_service_account.taskflow_sa.email
}
