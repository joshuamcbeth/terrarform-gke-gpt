output "gke_endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.gke_cluster.endpoint
}

output "kubeconfig" {
  description = "Kubeconfig for accessing the cluster"
  value = <<EOT
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate}
    server: https://${google_container_cluster.gke_cluster.endpoint}
  name: ${var.cluster_name}
contexts:
- context:
    cluster: ${var.cluster_name}
    user: ${var.cluster_name}
  name: ${var.cluster_name}
current-context: ${var.cluster_name}
users:
- name: ${var.cluster_name}
  user:
    auth-provider:
      name: gcp
EOT
}
