#!/usr/bin/env bash
#
## The purpose of this script is to create or update the clusetr
## secret in the argocd namespace.
#
# Usage: create-cluster-secret.sh [options]
#
set -euo pipefail

CLUSTER_PATH=""

usage() {
  cat << EOF
Usage: ${0} [options]

-p|--path PATH   The path to the cluster definition we need to update
-h|--help           Display this help message

EOF
  if [[ ${#} -gt 0 ]]; then
    echo "Error: ${*}"
    exit 1
  fi
}

## Responisble for updating the cluster secret
update_cluster_secret() {
  echo "Updating the cluster secret for: \"${CLUSTER_PATH}\""
  ## We use the cluster definition file as the helm values for the
  ## charts/cluster-registration chart
  if ! helm template \
    --values "${CLUSTER_PATH}" \
    charts/cluster-registration | kubectl -n argocd apply -f - > /dev/null; then
    return 1
  fi
  echo "Successfully updated the cluster secret"
}

## Parse the command line arguments
while [[ ${#} -gt 0 ]]; do
  case ${1} in
    -p | --path)
      CLUSTER_PATH="${2}"
      shift
      ;;
    -h | --help)
      usage
      ;;
    *)
      usage "Unknown argument: ${1}"
      ;;
  esac
  shift
done

## Check the cluster definition file exists
if [[ ! -f ${CLUSTER_PATH}   ]]; then
  usage "Cluster definition file not found: ${CLUSTER_PATH}"
fi

if ! update_cluster_secret "${CLUSTER_PATH}"; then
  usage "Failed to update cluster secret"
fi
