#!/usr/bin/env bash
#
# Script to provision clusters, install ArgoCD, and apply Kustomize configurations

set -euo pipefail

## The cluster name to use for the local development
CLUSTER_NAME=""
CREDENTIALS=false
ARGOCD_VERSION="7.8.5"
GITHUB_USER="gambol99"

usage() {
  cat << EOF
Usage: ${0} [options]

Options:
  -C, --credentials       Set the credentials for the platform repository
  -c, --cluster            Set the cluster name (default: "")
  -G, --github-user        Set the GitHub user (default: "${GITHUB_USER}")
  -g, --github-token       Set the GitHub token (default: "GITHUB_TOKEN")
  -h, --help               Show this help message and exit
EOF
  if [[ ${#} -gt 0   ]]; then
    echo "Error: ${*}"
    exit 1
  fi
}

# Function to setup a cluster
setup_cluster() {
  local cluster_name=$1
  local cluster_context="kind-${cluster_name}"

  echo "Provisioning Cluster: \"${cluster_name}\""
  # Create cluster
  kind create cluster --name "${cluster_name}" 2> /dev/null

  # Check if ArgoCD deployments are already present
  if kubectl get deployments -n argocd --context "${cluster_context}" 2>&1 | grep "No resources found" > /dev/null; then
    echo "Provisioning ArgoCD on cluster: \"${cluster_name}\""
    # Create ArgoCD namespace
    kubectl create namespace argocd --context "${cluster_context}" > /dev/null
    # Install ArgoCD
    if ! helm upgrade -n argocd --install argocd argo/argo-cd --version "${ARGOCD_VERSION}" > /dev/null; then
      usage "Failed to install ArgoCD on cluster: \"${cluster_name}\", ensure you have the repository configured"
    fi
    # Wait for ArgoCD to be ready
  fi
  echo "Waiting for ArgoCD pods to be ready..."
  kubectl -n argocd wait \
    --for=condition=Ready pods \
    --all -l app.kubernetes.io/name=argocd-repo-server \
    --timeout=90s \
    --context "${cluster_context}" > /dev/null
}

## Used to provision the credentials for the platform repository
setup_credentails() {
  local platform_repository=$1

  if [[ -z ${GITHUB_TOKEN}   ]]; then
    usage "GitHub token is not set"
  fi

  cat << EOF | kubectl apply -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: credentials-platform
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  type: git
  url: ${platform_repository}
  username: ${GITHUB_USER}
  password: ${GITHUB_TOKEN}
EOF
}

## Used to bootstrap the cluster with the platform repository
setup_application() {
  local platform_repo=$1
  local platform_revision=$2
  local cluster_name=$3

  cat << EOF | kubectl apply -f -
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bootstrap
  namespace: argocd
spec:
  ## The project to use for the application
  project: default
  ## The source is patched in the overlay
  source:
    repoURL: ${platform_repo}
    targetRevision: ${platform_revision}
    path: kustomize/overlays/standalone
    kustomize:
      patches:
        - target:
            kind: ApplicationSet
            name: system-platform
          patch: |
            - op: replace
              path: /spec/generators/0/git/repoURL
              value: ${platform_repo}
            - op: replace
              path: /spec/generators/0/git/revision
              value: ${platform_revision}
            - op: replace
              path: /spec/generators/0/git/files/0/path
              value: release/local/clusters/${cluster_name}.yaml

  ## The destination to deploy the resources
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd

  ## The sync policy to use for the application
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    retry:
      limit: 20
      backoff:
        duration: 20s
        maxDuration: 5m
    syncOptions:
      - CreateNamespace=false
      - ServerSideApply=true
EOF
}

## Parse the command line arguments
while [[ ${#} -gt 0   ]]; do
  case "${1}" in
    -h | --help)
      usage
      exit 0
      ;;
    -g | --github-token)
      GITHUB_TOKEN="${2}"
      shift
      ;;
    -G | --github-user)
      GITHUB_USER="${2}"
      shift
      ;;
    -c | --cluster)
      CLUSTER_NAME="${2}"
      shift
      ;;
    -C | --credentials)
      CREDENTIALS=true
      shift
      ;;
    *)
      shift
      ;;
  esac
done

## Check the cluster name is set
if [[ -z ${CLUSTER_NAME}   ]]; then
  usage "Cluster name is not set, please use the -c|--cluster option"
fi

## Check the cluster definition exists
if [[ ! -f "release/local/clusters/${CLUSTER_NAME}.yaml" ]]; then
  usage "Cluster definition for \"${CLUSTER_NAME}\" not found"
fi

## Check we have a repository to use
platform_repo=$(grep "platform_repository" "release/local/clusters/${CLUSTER_NAME}.yaml" | cut -d' ' -f2)
platform_revision=$(grep "platform_revision" "release/local/clusters/${CLUSTER_NAME}.yaml" | cut -d' ' -f2)

## Check we have a repository
if [[ -z ${platform_repo}   ]]; then
  usage "Invalid cluster definition for \"${CLUSTER_NAME}\""
fi

## Check we have a revision
if [[ -z ${platform_revision}   ]]; then
  usage "Invalid cluster definition for \"${CLUSTER_NAME}\""
fi

## Step: Provision the cluster
if ! setup_cluster "${CLUSTER_NAME}"; then
  usage "Failed to setup cluster: \"${CLUSTER_NAME}\""
fi

## Step: Provision the credentials if required
if [[ ${CREDENTIALS} == "true"   ]]; then
  if ! setup_credentails "${platform_repo}"; then
    usage "Failed to setup credentials for \"${CLUSTER_NAME}\""
  fi
fi

## Step: Bootstrap the cluster for Application
if ! setup_application "${platform_repo}" "${platform_revision}" "${CLUSTER_NAME}"; then
  usage "Failed to bootstrap cluster: \"${CLUSTER_NAME}\""
fi

echo "Successfully provisioned cluster: \"${CLUSTER_NAME}\""
