#!/usr/bin/env bash 
#
## This script generates the policies for the kyverno policies directory 
#
set -e

# Set colors for terminal output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

cat <<EOF
# Kyverno Policies

## Overview

Kyverno is a policy engine designed for Kubernetes that validates, mutates, and generates configurations using policies as Kubernetes resources. It provides key features like:

- Policy validation and enforcement
- Resource mutation and generation 
- Image verification and security controls
- Audit logging and reporting
- Admission control webhooks

The following policies are shipped by default in this platform to enforce security best practices, resource management, and operational standards.

For detailed information about Kyverno's capabilities, refer to the [official documentation](https://kyverno.io/docs/) or [policy library](https://kyverno.io/policies/).

---
EOF

# Find all policy.yaml files in the kyverno directory
POLICY_FILES=$(find addons/kustomize/oss/kyverno -name "policy.yaml")

if [ -z "$POLICY_FILES" ]; then
  echo "No policy files found at addons/kustomize/oss/kyverno/**/policy.yaml"
  exit 1
fi

# Counter for policies
COUNT=0

for POLICY_FILE in $POLICY_FILES; do
  # Get policy directory name which often indicates the purpose
  POLICY_DIR=$(dirname "$POLICY_FILE" | xargs basename)
  
  # Extract policy information using yq
  POLICY_NAME=$(yq e '.metadata.name' "$POLICY_FILE")
  POLICY_KIND=$(yq e '.kind' "$POLICY_FILE")
  POLICY_DESCRIPTION=$(yq e '.metadata.annotations["policies.kyverno.io/description"] // "No description provided"' "$POLICY_FILE")
  POLICY_CATEGORY=$(yq e '.metadata.annotations["policies.kyverno.io/category"] // "Uncategorized"' "$POLICY_FILE")
  POLICY_SEVERITY=$(yq e '.metadata.annotations["policies.kyverno.io/severity"] // "medium"' "$POLICY_FILE")
  POLICY_RULES=$(yq e '.spec.rules[].name' "$POLICY_FILE")
  
  # Determine if this is a cluster or namespaced policy
  POLICY_SCOPE="Namespaced"
  if [[ "$POLICY_KIND" == "ClusterPolicy" ]]; then
    POLICY_SCOPE="Cluster-wide"
  fi
  
  # Output policy as markdown
  echo "## :material-shield-lock: Rule: $POLICY_NAME"
  echo ""
  echo "**Category:** $POLICY_CATEGORY | **Severity:** $POLICY_SEVERITY | **Scope:** $POLICY_SCOPE"
  echo ""
  echo "$POLICY_DESCRIPTION"
  echo ""
  
  # Section for rules
  echo "**Rules**"
  echo ""
  for RULE in $POLICY_RULES; do
    RULE_TYPE=""
    if yq e '.spec.rules[] | select(.name == "'"$RULE"'") | has("validate")' "$POLICY_FILE" | grep -q "true"; then
      RULE_TYPE="Validation"
    elif yq e '.spec.rules[] | select(.name == "'"$RULE"'") | has("mutate")' "$POLICY_FILE" | grep -q "true"; then
      RULE_TYPE="Mutation"
    elif yq e '.spec.rules[] | select(.name == "'"$RULE"'") | has("generate")' "$POLICY_FILE" | grep -q "true"; then
      RULE_TYPE="Generation"
    fi
    
    echo "- **$RULE** ($RULE_TYPE)"
    
    # Try to extract match resources for additional context
    RESOURCES=$(yq e '.spec.rules[] | select(.name == "'"$RULE"'") | .match.resources.kinds[]' "$POLICY_FILE" 2>/dev/null || echo "")
    if [ ! -z "$RESOURCES" ]; then
      echo "  - Applies to: $RESOURCES"
    fi
    
    echo ""
  done
  
  echo "---"
  echo ""
  
  COUNT=$((COUNT + 1))
done

echo "**Total Policies: $COUNT**"