#!/usr/bin/env bash
#
## This script validates a hub cluster definition file to ensure it is correct and complete
## It checks for required fields, cluster type, Git repositories, enabled features,
## cloud vendor configuration, and paths and names.
##
## Usage:
##   ./validate-cluster-definition.sh <cluster-definition.yaml>
##
## Example:
##   ./validate-cluster-definition.sh release/hub/clusters/hub.yaml
#

set -e

# shellcheck disable=SC2155

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Usage information
function show_usage() {
  echo "Usage: $0 <cluster-definition.yaml>"
  echo "Validates a hub cluster definition file"
  exit 1
}

# Check if yq is installed
if ! command -v yq &> /dev/null; then
  echo -e "${RED}Error: yq is required but not installed${NC}"
  echo "Install with: wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq && chmod +x /usr/local/bin/yq"
  exit 1
fi

# Validate arguments
if [ $# -ne 1 ]; then
  show_usage
fi

CLUSTER_FILE=$1

if [ ! -f "$CLUSTER_FILE" ]; then
  echo -e "${RED}Error: Cluster file '$CLUSTER_FILE' not found${NC}"
  exit 1
fi

echo -e "${GREEN}Validating hub cluster definition: ${YELLOW}$CLUSTER_FILE${NC}"
echo "----------------------------------------"

# Check if cluster is enabled
function check_enabled() {
  local enabled

  enabled=$(yq e '.enabled' "$CLUSTER_FILE")
  if [ "$enabled" == "true" ]; then
    echo -e "${GREEN}✓ Cluster is enabled${NC}"
  else
    echo -e "${YELLOW}Warning: Cluster is disabled${NC}"
  fi
}

# Check required fields
function check_required_fields() {
  local fields=("cluster_name" "cloud_vendor" "environment" "tenant_repository"
    "tenant_revision" "tenant_path" "platform_repository"
    "platform_revision" "platform_path" "cluster_type" "tenant")

  for field in "${fields[@]}"; do
    if ! yq e ".$field" "$CLUSTER_FILE" > /dev/null 2>&1 || [ "$(yq e ".$field" "$CLUSTER_FILE")" == "null" ]; then
      echo -e "${RED}Error: Required field '$field' is missing or null${NC}"
    else
      echo -e "${GREEN}✓ Found required field: $field = $(yq e ".$field" "$CLUSTER_FILE")${NC}"
    fi
  done
}

# Check cluster type
function check_cluster_type() {
  local cluster_type

  cluster_type=$(yq e '.cluster_type' "$CLUSTER_FILE")

  if [ "$cluster_type" == "hub" ] || [ "$cluster_type" == "spoke" ] || [ "$cluster_type" == "standalone" ]; then
    echo -e "${GREEN}✓ Valid cluster type: $cluster_type${NC}"
  else
    echo -e "${RED}Error: Invalid cluster type '$cluster_type'. Must be 'hub', 'spoke', or 'standalone'${NC}"
  fi
}

# Check Git repositories accessibility
function check_repositories() {
  echo -e "\n${GREEN}Checking repositories:${NC}"

  local tenant_repo=$(yq e '.tenant_repository' "$CLUSTER_FILE")
  local platform_repo=$(yq e '.platform_repository' "$CLUSTER_FILE")

  # Basic format validation
  if [[ ! $tenant_repo =~ ^https://.*\.git$  ]]; then
    echo -e "${YELLOW}Warning: Tenant repository URL doesn't match expected format (https://*.git)${NC}"
  fi

  if [[ ! $platform_repo =~ ^https://.*\.git$  ]]; then
    echo -e "${YELLOW}Warning: Platform repository URL doesn't match expected format (https://*.git)${NC}"
  fi
}

# Check enabled features
function check_features() {
  echo -e "\n${GREEN}Checking enabled features:${NC}"

  # Get all keys from the labels section
  local all_labels=$(yq e '.labels | keys | .[]' "$CLUSTER_FILE" || echo "")

  if [ -z "$all_labels" ]; then
    echo -e "${YELLOW}Warning: No labels defined in the cluster definition${NC}"
    return
  fi

  # Filter to find only feature flags (those starting with enable_)
  local feature_flags=()
  local non_feature_labels=()
  local invalid_value_labels=()
  local enabled_count=0

  for label in $all_labels; do
    # Check if label starts with enable_
    if [[ $label =~ ^enable_ ]]; then
      local value=$(yq e ".labels.$label" "$CLUSTER_FILE")

      # Validate value is true or false
      if [ "$value" == "true" ] || [ "$value" == "false" ]; then
        feature_flags+=("$label")

        # Count enabled features
        if [ "$value" == "true" ]; then
          local feature_name=${label#enable_}
          echo -e "${GREEN}✓ Feature enabled: $feature_name${NC}"
          enabled_count=$((enabled_count + 1))
        fi
      else
        invalid_value_labels+=("$label=$value")
      fi
    else
      non_feature_labels+=("$label")
    fi
  done

  # Summary information
  echo -e "${GREEN}Found ${#feature_flags[@]} feature flags, $enabled_count enabled${NC}"

  # Report non-feature labels
  if [ ${#non_feature_labels[@]} -gt 0 ]; then
    echo -e "${YELLOW}Non-feature labels found (doesn't start with 'enable_'):${NC}"
    for label in "${non_feature_labels[@]}"; do
      echo -e "${YELLOW}  - $label${NC}"
    done
  fi

  # Report invalid feature values
  if [ ${#invalid_value_labels[@]} -gt 0 ]; then
    echo -e "${RED}Error: Feature flags with invalid values (must be 'true' or 'false'):${NC}"
    for label in "${invalid_value_labels[@]}"; do
      echo -e "${RED}  - $label${NC}"
    done
  fi

  # Keep dependency checks
  if [ "$(yq e '.labels.enable_kube_prometheus_stack // "false"' "$CLUSTER_FILE")" == "true" ] \
                                                                                              && [ "$(yq e '.labels.enable_prometheus // "false"' "$CLUSTER_FILE")" == "true" ]; then
    echo -e "${YELLOW}Warning: Both kube_prometheus_stack and prometheus are enabled. This might cause conflicts${NC}"
  fi

  # Validate specifically for hub clusters
  if [ "$(yq e '.cluster_type' "$CLUSTER_FILE")" == "hub" ]; then
    if [ "$(yq e '.labels.enable_argocd // "false"' "$CLUSTER_FILE")" != "true" ]; then
      echo -e "${YELLOW}Warning: Hub cluster should have ArgoCD enabled${NC}"
    fi

    if [ "$(yq e '.labels.enable_cert_manager // "false"' "$CLUSTER_FILE")" != "true" ]; then
      echo -e "${YELLOW}Warning: Hub cluster should have cert-manager enabled${NC}"
    fi
  fi
}

# Check cloud vendor specific configuration
function check_cloud_vendor() {
  local vendor=$(yq e '.cloud_vendor' "$CLUSTER_FILE")
  echo -e "\n${GREEN}Checking cloud vendor configuration for: $vendor${NC}"

  case $vendor in
    aws)
      # Check for AWS specific fields
      local region=$(yq e '.aws_region // ""' "$CLUSTER_FILE")
      if [ -z "$region" ]; then
        echo -e "${YELLOW}Warning: No AWS region specified${NC}"
      else
        echo -e "${GREEN}✓ AWS Region: $region${NC}"
      fi
      ;;

    azure | azurerm)
      # Check for Azure specific fields
      local resource_group=$(yq e '.resource_group // ""' "$CLUSTER_FILE")
      if [ -z "$resource_group" ]; then
        echo -e "${YELLOW}Warning: No Azure resource group specified${NC}"
      else
        echo -e "${GREEN}✓ Azure Resource Group: $resource_group${NC}"
      fi
      ;;

    google | gcp)
      # Check for GCP specific fields
      local project=$(yq e '.project_id // ""' "$CLUSTER_FILE")
      if [ -z "$project" ]; then
        echo -e "${YELLOW}Warning: No GCP project ID specified${NC}"
      else
        echo -e "${GREEN}✓ GCP Project ID: $project${NC}"
      fi
      ;;

    kind)
      echo -e "${GREEN}✓ Using kind for local development${NC}"
      ;;

    *)
      echo -e "${YELLOW}Warning: Unknown cloud vendor: $vendor${NC}"
      ;;
  esac
}

# Run all checks
check_required_fields
check_cluster_type
check_repositories
check_features
check_cloud_vendor

echo -e "\n${GREEN}Validation complete!${NC}"
