terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.0.12"
    }
  }
}

provider "kind" {}

# This resource defines our local Kubernetes cluster
resource "kind_cluster" "default" {
  name = "ci-cd-cluster"
  
  # This config allows the LoadBalancer Service to expose a port on the host machine
  kind_config {
    kind = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"
    nodes {
      role = "control-plane"
      extra_port_mappings {
        # Maps port 8080 on the host to port 80 on the Ingress node
        container_port = 80
        host_port      = 8080
        protocol       = "TCP"
      }
    }
  }
}

# This output gives the CI/CD pipeline the configuration needed to connect to the cluster
output "kubeconfig" {
  value     = kind_cluster.default.kubeconfig
  sensitive = true
}