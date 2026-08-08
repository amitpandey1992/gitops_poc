# TaskFlow GitOps POC

This repository contains the Infrastructure as Code (Terraform) and GitOps (Helm + ArgoCD) configuration for the TaskFlow application.

## Directory Structure
- `terraform/`: Contains Terraform configuration for GCP resources (Cloud SQL, WIF, IAM) and GKE setup.
- `.github/workflows/`: CI pipeline configuration using GitHub Actions.
- `helm-chart/`: Helm chart for deploying the application.
- `argocd/`: ArgoCD application manifests.

## Prerequisites
- GCP Project with GKE cluster available
- GitHub repository setup
- Artifactory for Docker images

## Getting Started

1. Configure variables in `terraform/terraform.tfvars` based on `terraform.tfvars.example`.
2. Apply Terraform configuration:
   ```sh
   cd terraform
   terraform init
   terraform apply
   ```
3. The CI/CD pipeline runs on pushes to `main`. It builds the app, pushes the image to Artifactory, and updates the Helm values.
4. ArgoCD automatically syncs changes applied to the helm chart to the GKE cluster.
