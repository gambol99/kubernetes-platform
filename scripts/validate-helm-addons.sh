#!/usr/bin/env bash 
#
## This script validates the addons/helm/ directory structure of the YAML files  
#
HELM_DIR="addons/helm"

set -e 

# Find all YAML files under the addons/helm/ directory
find $HELM_DIR -name "*.yaml" | while read -r file; do  
  echo "--> Validating $file"
  # Iterate over each item in the list
  yq "$file" -o=json | jq -c '.[]' | while read -r item; do
    # Extract fields from the current item
    feature=$(echo "$item" | jq -r '.feature')
    repository=$(echo "$item" | jq -r '.repository')
    namespace=$(echo "$item" | jq -r '.namespace')
    version=$(echo "$item" | jq -r '.version')

    # Check we have a feature flag 
    if [[ -z $feature ]]; then
      echo "Error: $file - helm.feature is empty"
    fi

    # Check if helm.repository is a https reference
    if [[ -z $repository ]]; then
      echo "Error: $file - helm.repository is empty"
    fi

    ## Check we have a namespace 
    if [[ -z $namespace ]]; then
      echo "Error: $file - helm.namespace is empty"
    fi

    # Check if helm.version is not empty
    if [[ -z $version ]]; then
      echo "Error: $file - helm.version is empty"
    fi
  done
done
