# CI/CD Pipeline for a Python Web App with Docker, Kubernetes, and Terraform

[![CI/CD Pipeline](https://github.com/pswitchy/cicd-flask-k8s/actions/workflows/deploy.yml/badge.svg)](https://github.com/pswitchy/cicd-flask-k8s/actions/workflows/deploy.yml)

This project demonstrates a complete, automated CI/CD pipeline for a simple Python Flask web application. The goal is to automate the entire process from a `git push` to a live application running in a Kubernetes cluster, using only local and open-source tools.

## Key Features

*   **Automated CI/CD**: Uses GitHub Actions to automatically test, build, and deploy the application.
*   **Infrastructure as Code (IaC)**: Uses Terraform to provision a local Kubernetes cluster on demand.
*   **Containerization**: The Python application is containerized using Docker for portability and consistency.
*   **Orchestration**: Deploys the application to a local Kubernetes cluster managed by **Kind** (Kubernetes in Docker).
*   **Automated Testing**: The pipeline runs `pytest` to ensure code quality before any deployment.

## Technology Stack

*   **Application**: Python 3.9+ with Flask
*   **Containerization**: Docker
*   **CI/CD**: GitHub Actions
*   **Infrastructure**: Terraform
*   **Kubernetes Cluster**: Kind (Kubernetes in Docker)
*   **Container Registry**: GitHub Container Registry (GHCR)
*   **Scripting**: Bash

## How It Works: The CI/CD Pipeline

The entire process is orchestrated by the `.github/workflows/deploy.yml` file and is triggered on every `git push` to the `main` branch.

1.  **Trigger**: A developer pushes code to the `main` branch of the GitHub repository.

2.  **Continuous Integration (CI)**:
    *   A GitHub-hosted runner checks out the code.
    *   Python dependencies are installed, and unit tests are run using `pytest`.
    *   If tests pass, the pipeline logs into the GitHub Container Registry (GHCR).
    *   A Docker image is built from the `Dockerfile`.
    *   The new Docker image is pushed to GHCR, tagged with the unique Git commit SHA.

3.  **Continuous Deployment (CD)**:
    *   Terraform is set up on the runner.
    *   `terraform apply` is executed to provision a fresh Kind Kubernetes cluster inside the runner's environment.
    *   The `deploy.sh` script is executed. It replaces the `IMAGE_PLACEHOLDER` in the Kubernetes manifest with the new image URL from GHCR.
    *   `kubectl apply` deploys the updated application to the Kind cluster.
    *   The pipeline waits for the deployment to successfully roll out.

## Project Structure

```
cicd-flask-k8s/
├── .github/workflows/
│   └── deploy.yml            # The main CI/CD pipeline
├── k8s/
│   ├── deployment.yaml       # Kubernetes Deployment manifest
│   └── service.yaml          # Kubernetes Service manifest
├── scripts/
│   └── deploy.sh             # Bash script for deployment logic
├── app/
│   ├── app.py                # The Flask web application
│   └── test_app.py           # Unit tests for the Flask app
├── .dockerignore
├── Dockerfile
├── main.tf                   # Terraform configuration for the Kind cluster
├── README.md                 # This file
└── requirements.txt          # Python dependencies
```

## Getting Started

### Prerequisites

Ensure you have the following tools installed on your local machine:
*   [Docker Desktop](https://www.docker.com/products/docker-desktop/)
*   [Python 3.9+](https://www.python.org/downloads/)
*   [Terraform](https://developer.hashicorp.com/terraform/downloads)
*   [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
*   [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

### Running the Automated Pipeline (Recommended)

1.  **Fork this Repository**: Click the "Fork" button at the top-right of this page.
2.  **Clone Your Fork**: `git clone https://github.com/your-username/cicd-flask-k8s.git`
3.  **Configure Repository Permissions**: For the pipeline to push Docker images, you must grant it the correct permissions.
    *   In your forked repository, go to **Settings** > **Actions** > **General**.
    *   Scroll down to **"Workflow permissions"**.
    *   Select the **"Read and write permissions"** option and click **Save**.
4.  **Push a Change**: Make a small change to any file (e.g., add a comment to `app/app.py`), then commit and push it to your `main` branch.
    ```bash
    git add .
    git commit -m "Triggering the pipeline"
    git push origin main
    ```
5.  **Observe the Pipeline**: Go to the **Actions** tab in your GitHub repository to watch the pipeline execute all the steps in real-time.

### Running Locally (For Development & Testing)

You can also run every step of the deployment process manually on your local machine.

1.  **Provision the Infrastructure**:
    ```bash
    # Initialize Terraform (only needed once)
    terraform init

    # Create the Kind cluster
    terraform apply -auto-approve
    ```

2.  **Build the Docker Image**:
    ```bash
    docker build -t flask-app:local .
    ```

3.  **Load the Image into the Kind Cluster**:
    *The Kind cluster runs inside Docker and cannot see your local Docker images by default. This command loads the image into the cluster.*
    ```bash
    kind load docker-image flask-app:local --name ci-cd-cluster
    ```

4.  **Deploy the Application**:
    *   **Important**: Manually edit `k8s/deployment.yaml` and change the `image:` value from `IMAGE_PLACEHOLDER` to `flask-app:local`.
    *   Apply the manifests:
    ```bash
    kubectl apply -f k8s/
    ```

5.  **Verify the Deployment**:
    ```bash
    # Check that the pods are running
    kubectl get pods

    # Access the application
    # The Terraform config maps port 8080 on your machine to the service
    curl http://localhost:8080
    ```
    You should see the output: `{"message":"Hello, DevOps World!","status":"ok"}`

6.  **Clean Up**:
    *Destroy the Kind cluster to free up resources.*
    ```bash
    terraform destroy -auto-approve
    ```

## Future Improvements

*   **Implement Helm**: Use Helm charts to package and manage the Kubernetes application for more complex deployments.
*   **Secrets Management**: Introduce a secrets manager like HashiCorp Vault or Kubernetes Secrets for handling sensitive data.
*   **Monitoring & Logging**: Integrate Prometheus and Grafana for monitoring, and an EFK (Elasticsearch, Fluentd, Kibana) stack for logging.
