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

set -e

KUSTOMIZE_DIRS=(
  "./kustomize/overlays"
  "./apps"
)

## Iterate the directories in the apps folder and check if we can render them
for x in "${KUSTOMIZE_DIRS[@]}"; do
  find "${x}" -maxdepth 2 -type d | sed '1d' | while read -r path; do
    if [[ -e "${path}/kustomization.yaml" ]]; then
      echo "--> Validating the application ${path}"
      if ! kustomize build "${path}" > /dev/null; then
        echo "Failed to render the application ${path}"
        exit 1
      fi
    fi
  done
done

