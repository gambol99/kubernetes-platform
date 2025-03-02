#!/usr/bin/env bash
#
## The purpose of the script is to validate and check the embedded helm charts in the repository
#
# Usage: ./validate-helm-charts.sh
#

HELM_CHARTS_DIR="./charts"

## Check the ct command is installed
if ! ct version > /dev/null 2>&1; then
  echo "ct command is not installed. Please install it first (brew install chart-testing)"
  exit 1
fi

## Iterate and validate the helm charts from the directory |
find "${HELM_CHARTS_DIR}" -maxdepth 1 -type d | sed '1d' | while read -r path; do
  echo "Validating the helm chart: ${path}"
  if ! ct lint --all --chart-dirs "${path}"; then
    echo "Failed to validate the helm chart: ${path}"
    exit 1
  fi
done
