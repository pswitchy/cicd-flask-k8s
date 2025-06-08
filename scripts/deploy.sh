#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if a Docker image name is provided
if [ -z "$1" ]; then
  echo "Error: Docker image name is required."
  echo "Usage: ./scripts/deploy.sh <your-image-name>"
  exit 1
fi

IMAGE_NAME=$1
K8S_DIR="k8s"

echo "🚀 Starting deployment of image: $IMAGE_NAME"

# Replace the placeholder in the deployment YAML with the actual image name
# Using a temporary file for sed compatibility between macOS and Linux
sed "s|IMAGE_PLACEHOLDER|$IMAGE_NAME|g" "$K8S_DIR/deployment.yaml" > "$K8S_DIR/deployment.yaml.tmp"
mv "$K8S_DIR/deployment.yaml.tmp" "$K8S_DIR/deployment.yaml"

echo "✅ Image placeholder replaced in deployment.yaml."
echo "📄 Applying Kubernetes manifests..."

# Apply the Kubernetes manifests
kubectl apply -f "$K8S_DIR/"

echo "⏳ Waiting for deployment to be ready..."
kubectl rollout status deployment/flask-app-deployment

echo "✅ Deployment successful!"