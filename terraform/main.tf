terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.0"

  backend "gcs" {
    bucket      = "terraform-gke-gpt-state"
    prefix      = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_service_account" "gke_node_sa" {
  account_id   = "gke-node"
  display_name = "GKE Node Service Account"
}

resource "google_container_cluster" "gke_cluster" {
  name     = var.cluster_name
  location = var.zone

  deletion_protection = false

  initial_node_count = var.node_count

  node_config {
    machine_type = var.node_machine_type
    service_account = google_service_account.gke_node_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  remove_default_node_pool = true
}

resource "google_container_node_pool" "gpt_nodes" {
  name       = "gpt-pool"
  cluster    = google_container_cluster.gke_cluster.name
  location   = var.zone

  initial_node_count = 1

  node_config {
    machine_type = var.node_machine_type
    service_account = google_service_account.gke_node_sa.email
    preemptible  = false
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  management {
    auto_upgrade = true
    auto_repair  = true
  }
}

# Enable the Kubernetes Engine API
resource "google_project_service" "container" {
  project = var.project_id
  service = "container.googleapis.com"

  disable_on_destroy = false
}

# Enable the Cloud Resource Manager API
resource "google_project_service" "cloudresourcemanager" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"

  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "gke_repo" {
  provider = google
  location = "us-central1"
  repository_id = "gke-repo"
  description   = "Docker repository for GKE cluster app images"
  format        = "DOCKER"

  labels = {
    environment = "prod"
  }
}
resource "google_project_iam_member" "gke_node_sa_role" {
  project = var.project_id
  role    = "roles/container.nodeServiceAccount"
  member  = "serviceAccount:${google_service_account.gke_node_sa.email}"
}