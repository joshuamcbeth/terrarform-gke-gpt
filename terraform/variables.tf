variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "terraform-gke-gpt"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "terraform-gke-gpt-cluster"
}

variable "node_count" {
  description = "Number of nodes in the cluster"
  type        = number
  default     = 1
}

variable "node_machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-micro"
}