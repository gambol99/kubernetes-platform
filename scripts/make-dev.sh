#!/usr/bin/env bash
#
# Script to provision clusters, install ArgoCD, and apply Kustomize configurations

set -euo pipefail

# Function to setup a cluster
setup_cluster() {
  local cluster_name=$1
  local cluster_context="kind-${cluster_name}"

  echo "Provisioning cluster: ${cluster_name}"
  # Create cluster
  kind create cluster --name "${cluster_name}"
  # Create ArgoCD namespace
  kubectl create namespace argocd --context "${cluster_context}" > /dev/null
  # Install ArgoCD
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --context "${cluster_context}" > /dev/null
  # Wait for ArgoCD to be ready
  echo "Waiting for ArgoCD pods to be ready..."
  kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s --context "${cluster_context}"
  # Apply Kustomize configurations
  echo "Applying Kustomize configurations for ${cluster_name}"
  kubectl apply -k "system/overlays/${cluster_name}" --context "${cluster_context}"
}

# Main execution
echo "Provisioning development clusters..."

setup_cluster "yel" || {
  echo "Failed to setup yellow cluster"
  exit 1
}
setup_cluster "grn" || {
  echo "Failed to setup green cluster"
  exit 1
}

echo "Setup completed successfully! (currently on 'grn' cluster)"
