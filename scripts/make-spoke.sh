#!/usr/bin/env bash

#
## The purpose of this script is to create an empty spoke cluster for the
## hub to deploy
#

usage() {
  cat << EOF
The purpose of this script is to onboard a new cluster to the platform.

Usage: $0 [options]

-c|--cluster-name <cluster-name>                The name of the cluster to create (ensure you've a cluster definition).
-h|--help                                       Show this help message.
EOF
  if [[ -n $1   ]]; then
    echo "Error: $1"
    exit 1
  fi
  exit 0
}

## Setup the spoke cluster
setup_spoke() {
  echo "Attempting to setup the spoke cluster: \"${CLUSTER_NAME}\""
  if ! kind create cluster --name "${CLUSTER_NAME}"; then
    return 1
  fi
  echo "Successfully setup the spoke cluster: \"${CLUSTER_NAME}\""
}

## Parse the command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -c | --cluster-name)
      CLUSTER_NAME="$2"
      shift 2
      ;;
    -h | --help)
      usage
      ;;
    *)
      usage "Invalid option: $1"
      ;;
  esac
done

## Setup the spoke cluster
setup_spoke || {
  echo "Failed to setup the spoke cluster"
  exit 1
}

