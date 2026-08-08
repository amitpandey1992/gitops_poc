variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "project-616fef18-15b8-4d6c-8a2"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "Existing GKE cluster name"
  type        = string
  default     = "java-gke-cluster"
}

variable "artifactory_url" {
  description = "Artifactory URL"
  type        = string
  default     = "my-jfrog-artifactory.duckdns.org/docker-local/taskflow"
}

variable "github_org" {
  description = "GitHub Organization or Username"
  type        = string
  default     = "amitpandey1992"
}

variable "github_repo" {
  description = "GitHub Repository Name"
  type        = string
  default     = "gitops_poc"
}

variable "db_instance_name" {
  description = "Cloud SQL Instance Name"
  type        = string
  default     = "taskflow-sql"
}

variable "db_name" {
  description = "Cloud SQL Database Name"
  type        = string
  default     = "taskflow_db"
}

variable "db_user" {
  description = "Cloud SQL Database User"
  type        = string
  default     = "taskflow_user"
}

variable "app_namespace" {
  description = "Kubernetes Namespace for the application"
  type        = string
  default     = "taskflow"
}

variable "wif_pool_id" {
  description = "Workload Identity Federation Pool ID"
  type        = string
  default     = "github-actions-pool"
}

variable "wif_provider_id" {
  description = "Workload Identity Federation Provider ID"
  type        = string
  default     = "github-actions-provider"
}
