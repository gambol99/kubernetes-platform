#!/usr/bin/env bash 
#
## This script validates all the cluster definitions in the release/hub/clusters directory
#

set -e 

## Find all .yaml files in folders with clusters/*.yaml in the release/hub/clusters and release/standalone/clusters directories
for cluster_file in $(find release/hub/clusters -name "*.yaml") $(find release/standalone/clusters -name "*.yaml"); do
  scripts/validate-cluster-definition.sh "$cluster_file"
done
