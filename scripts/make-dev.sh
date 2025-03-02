#!/usr/bin/env bash
#
# Script to provision clusters, install ArgoCD, and apply Kustomize configurations

set -euo pipefail

## The cluster name to use for the local development
CLUSTER_NAME="dev"
CLUSTER_TYPE="standalone"
CREDENTIALS=false
ARGOCD_VERSION="7.8.5"
GITHUB_USER="gambol99"

usage() {
  cat << EOF
Usage: ${0} [options]

Options:
  -C, --credentials        Set the credentials for the platform repository (default: ${CREDENTIALS})
  -c, --cluster NAME       Set the cluster name (default: ${CLUSTER_NAME})
  -G, --github-user USER   Set the GitHub user (default: ${GITHUB_USER})
  -g, --github-token PASS  Set the GitHub token (default: "GITHUB_TOKEN")
  -t, --type TYPE          The type of cluster to create, i.e. hub or standalone (default: ${CLUSTER_TYPE})
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

  echo "Provisioning Cluster: \"${cluster_name}\", Type: \"${CLUSTER_TYPE}\""

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

## Provision a standalone cluster
setup_bootstrap() {
  local cluster_definition

  cluster_definition="release/${CLUSTER_TYPE}/clusters/${CLUSTER_NAME}.yaml"

  ## Check the cluster definition exists
  if [[ ! -f ${cluster_definition} ]]; then
    usage "Cluster definition for \"${CLUSTER_NAME}\" not found"
  fi

  ## Check we have a repository to use
  platform_repo=$(grep "platform_repository" "${cluster_definition}" | cut -d' ' -f2)
  platform_revision=$(grep "platform_revision" "${cluster_definition}" | cut -d' ' -f2)

  ## Check we have a repository
  if [[ -z ${platform_repo}   ]]; then
    usage "Invalid cluster definition for \"${CLUSTER_NAME}\""
  fi

  ## Check we have a revision
  if [[ -z ${platform_revision}   ]]; then
    usage "Invalid cluster definition for \"${CLUSTER_NAME}\""
  fi

  ## Check if we need to provision the repository secret
  if [[ ${CREDENTIALS} == "true"   ]]; then
    if ! setup_credentails "${platform_repo}"; then
      usage "Failed to setup credentials for \"${CLUSTER_NAME}\""
    fi
  fi

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
    path: kustomize/overlays/${CLUSTER_TYPE}
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
              value: ${cluster_definition}

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

  echo "Successfully provisioned cluster: \"${CLUSTER_NAME}\""
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
      shift 2
      ;;
    -G | --github-user)
      GITHUB_USER="${2}"
      shift 2
      ;;
    -c | --cluster)
      CLUSTER_NAME="${2}"
      shift 2
      ;;
    -C | --credentials)
      CREDENTIALS=true
      shift 1
      ;;
    -t | --cluster-type)
      CLUSTER_TYPE="${2}"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

## Check cluster type is hub or standalone
if [[ ${CLUSTER_TYPE} != "hub" && ${CLUSTER_TYPE} != "standalone"       ]]; then
  usage "Invalid cluster type: \"${CLUSTER_TYPE}\", must be 'hub' or 'standalone'"
fi

## Step: Provision the cluster
setup_cluster "${CLUSTER_NAME}"   || usage "Failed to setup cluster"
## Step: bootstrap the platform
setup_bootstrap "${CLUSTER_NAME}" || usage "Failed to setup the bootstrap application"
