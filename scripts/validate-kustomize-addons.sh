#!/usr/bin/env bash
#
## This script validates the addons/kustomize/ directory structure of the YAML files
#
KUSTOMIZE_DIR="addons/kustomize"

set -e 

# Find all YAML files under the addons/helm/ directory
find $KUSTOMIZE_DIR -name "kustomize.yaml" | while read -r file; do  
  echo "--> Validating $file"
  # Iterate over each item in the list
  if ! kubeconform --schema-location ./addons/kustomize/schema.json --verbose "$file"; then
    echo "Error: $file - invalid kustomize file"
    exit 1
  fi
done
