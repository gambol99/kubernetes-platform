#!/usr/bin/env bash

# Directory containing Kyverno policies
POLICY_DIR="addons/kustomize/oss/kyverno/base"

# Check if kyverno CLI is installed
if ! command -v kyverno &> /dev/null; then
  echo "Kyverno CLI could not be found. Please install it first."
  exit 1
fi

# Validate each policy file in the directory
if ! kyverno test ${POLICY_DIR}; then
  echo "Failed to validate Kyverno policies"
  exit 1
fi
