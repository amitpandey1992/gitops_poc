# ─────────────────────────────────────────────────────────────────────────────
# WORKLOAD IDENTITY FEDERATION
# ─────────────────────────────────────────────────────────────────────────────

# ── 1. GitHub OIDC Provider ──────────────────────────────────────────────────
resource "google_iam_workload_identity_pool_provider" "github_taskflow" {
  workload_identity_pool_id          = var.wif_pool_id
  workload_identity_pool_provider_id = "github-taskflow-provider"
  project                            = var.project_id
  display_name                       = "GitHub Actions — gitops_poc"

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  attribute_condition = "assertion.repository == '${var.github_org}/${var.github_repo}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# ── 2. WIF Binding: GitHub Actions → taskflow-sa ─────────────────────────────
resource "google_service_account_iam_member" "github_wif_binding" {
  service_account_id = google_service_account.taskflow_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${var.project_id}/locations/global/workloadIdentityPools/${var.wif_pool_id}/attribute.repository/${var.github_org}/${var.github_repo}"
}

# ── 3. GKE Workload Identity: K8s SA → taskflow-sa ───────────────────────────
resource "google_service_account_iam_member" "gke_workload_identity" {
  service_account_id = google_service_account.taskflow_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.app_namespace}/taskflow-sa]"
}
