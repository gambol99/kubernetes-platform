#!/usr/bin/env bash 
#
## Description:
#   Validate the kustomize configuration from overlay to applications
#
## Usage:
#   validate-kustomize.sh
#
## Example:
#   ./scripts/validate-kustomize.sh

set -ex

KUSTOMIZE_OVERLAYS=./kustomize/overlays/release 
KUSTOMIZE_APPS=./kustomize/apps

## Check if we can render the overlay 
if ! kustomize build ${KUSTOMIZE_OVERLAYS} > /dev/null; then
  echo "Failed to render the overlay ${KUSTOMIZE_OVERLAYS}"
  exit 1
fi

## Iterate the directories in the apps folder and check if we can render them 
find ${KUSTOMIZE_APPS} -maxdepth 1 -type d | gsed '1d' | while read -r path; do
  echo "--> Validating the application ${path}"
  if ! kustomize build ${path} > /dev/null; then
    echo "Failed to render the application ${path}"
    exit 1
  fi
done