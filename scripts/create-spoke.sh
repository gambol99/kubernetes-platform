#!/usr/bin/env bash 

#
## The purpose of this script is to onboard a new cluster to the platform.
## It will deploy the necessary resources to the cluster to allow it to be
## managed by the platform.
#

## The tenant repository to use for the spoke cluster
TENANT_REPOSITORY="https://github.com/gambol99/kubernetes-platform"
## The branch to use for the tenant repository
TENANT_BRANCH="main"
## The platform repository to use for the spoke cluster
PLATFORM_REPOSITORY="https://github.com/gambol99/kubernetes-platform"
## The branch to use for the platform repository
PLATFORM_BRANCH="main"

usage() {
  cat <<EOF
The purpose of this script is to onboard a new cluster to the platform.

Usage: $0 [options]

-B|--platform-branch <platform-branch>          The branch to use for the platform (default: ${PLATFORM_BRANCH}).
-b|--tenant-branch <tenant-branch>              The branch to use for the tenant (default: ${TENANT_BRANCH}).
-c|--cluster-name <cluster-name>                The name of the cluster to create (ensure you've a cluster definition).
-P|--platform-repository <platform-repository>  The repository to use for the platform (default: ${PLATFORM_REPOSITORY}).
-t|--tenant-repository <tenant-repository>      The repository to use for the tenant (default: ${TENANT_REPOSITORY}).
-h|--help                                       Show this help message.
EOF
  if [[ -n "$1" ]]; then
    echo "Error: $1"
    exit 1
  fi
  exit 0
}

## Setup the spoke cluster 
setup_spoke() {
  echo "Attempting to setup the spoke cluster: ${CLUSTER_NAME}"
  echo "Using the repository: ${TENANT_REPOSITORY}"
  echo "Using the branch: ${TENANT_BRANCH}"
  echo "Using the platform repository: ${PLATFORM_REPOSITORY}"
  echo "Using the platform branch: ${PLATFORM_BRANCH}"


}


## Parse the command line arguments 
while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--cluster-name)
      CLUSTER_NAME="$2"
      shift 2
      ;;
    -t|--tenant-repository)
      TENANT_REPOSITORY="$2"
      shift 2
      ;;
    -b|--tenant-branch)
      TENANT_BRANCH="$2"
      shift 2
      ;;
    -h|--help)
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