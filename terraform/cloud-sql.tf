resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "google_sql_database_instance" "default" {
  name                = var.db_instance_name
  database_version    = "POSTGRES_15"
  region              = var.region
  project             = var.project_id
  deletion_protection = false # For dev environments

  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "default" {
  name     = var.db_name
  instance = google_sql_database_instance.default.name
  project  = var.project_id
}

resource "google_sql_user" "default" {
  name     = var.db_user
  instance = google_sql_database_instance.default.name
  password = random_password.db_password.result
  project  = var.project_id
}

resource "google_secret_manager_secret" "db_password" {
  secret_id = "${var.db_instance_name}-password"
  project   = var.project_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
}
