# Description

This project deploys a simple GPT2-Medium API service in an GKE cluster using GitHub Actions, Terraform, and Helm.

# Layout

The project is laid out as a monorepo with component subfolders.

    apps/
    apps/gpt/
    apps/gpt/helm/
    terraform/

# Usage

After provisioning the service can be accessed via HTTP POST with a JSON payload at (loadbalancer IP):8000/generate, and will respond with the generated text in a JSON payload.

The input JSON payload should resemble the following:

    {
        "prompt": "(a prompt)",
        "max_new_tokens": 256,
    }

The output JSON payload will resemble the following:
    {
        "completion": "(completion of prompt)"
    }

Note that max_new_tokens is optional and defaults to 256.

It is fairly easy to test with httpie:

    http POST http://localhost:8000/generate prompt="Once upon a time," | jq -r '.completion'

To discover the external IP of the load balancer, authenticate to the cluster and execute:

    kubectl describe svc gpt

# Configuration

The Terraform has several configurable variables listed below with their default value and description.

- project_id: GCP project ID (terraform-gke-gpt)
- region: GCP region (us-central1)
- zone: GCP zone (us-central1-a)
- cluster_name: GKE cluster name (terraform-gke-gpt-cluster)
- node_count: Number of nodes in the cluster (1)
- node_machine_type: Machine type for nodes (e2-medium)

# Performance

With 16 node CPUs (of which around 8 seem to be utilized), it takes around 24 seconds to generate a maximum legth completion at 256 max_new_tokens.

The deployed service has access to 2 node CPUs and takes around 60 seconds to generate a maximum length completion at 256 max_new_tokens.

