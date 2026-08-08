# ─────────────────────────────────────────────────────────────────────────────
# WORKLOAD IDENTITY FEDERATION
# Strategy: Existing WIF Pool (from prev POC) → Add new bindings only
# ─────────────────────────────────────────────────────────────────────────────

# Reference existing WIF pool (DO NOT recreate)
data "google_iam_workload_identity_pool" "existing_pool" {
  workload_identity_pool_id = var.wif_pool_id
  project                   = var.project_id
}

# ── 1. GitHub OIDC Provider (create if not exists) ────────────────────────────
# If this already exists from previous POC with same name, rename provider_id
resource "google_iam_workload_identity_pool_provider" "github_taskflow" {
  workload_identity_pool_id          = data.google_iam_workload_identity_pool.existing_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-taskflow-provider" # unique name!
  project                            = var.project_id
  display_name                       = "GitHub Actions — gitops_poc"

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  # 🔐 Only allow THIS specific repo — Security best practice!
  attribute_condition = "assertion.repository == '${var.github_org}/${var.github_repo}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# ── 2. WIF Binding: GitHub Actions → taskflow-sa ─────────────────────────────
# This allows GitHub Actions (from gitops_poc repo only) to impersonate taskflow-sa
resource "google_service_account_iam_member" "github_wif_binding" {
  service_account_id = google_service_account.taskflow_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member = "principalSet://iam.googleapis.com/${data.google_iam_workload_identity_pool.existing_pool.name}/attribute.repository/${var.github_org}/${var.github_repo}"
}

# ── 3. GKE Workload Identity: K8s SA → taskflow-sa ───────────────────────────
# This allows pods in taskflow namespace to use taskflow-sa (no mounted keys!)
resource "google_service_account_iam_member" "gke_workload_identity" {
  service_account_id = google_service_account.taskflow_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.app_namespace}/taskflow-sa]"
}

# ── OUTPUTS (copy these to GitHub Secrets) ────────────────────────────────────
output "wif_provider_resource_name" {
  description = "Value for GitHub Secret: WIF_PROVIDER"
  value       = google_iam_workload_identity_pool_provider.github_taskflow.name
}
