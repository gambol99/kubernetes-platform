#!/usr/bin/env bash
#
## This script is used to run the check suite for the kubernetes platform
##

BATS_OPTIONS=${BATS_OPTIONS:-""}
CLOUD="kind"
CLUSTER_TYPE="standalone"
UNITS="tests/e2e/integration"
GIT_COMMIT=$(git rev-parse HEAD)

usage() {
  cat << EOF
Usage: $0 [options]

--cloud <NAME>         Cloud provider name to run against (defaults: ${CLOUD})
--cluster-type <TYPE>  Cluster type to run against (defaults: ${CLUSTER_TYPE})
--help                 Display this help message

EOF
  if [[ -n ${*}   ]]; then
    echo "Error: ${1}"
    exit 1
  fi

  exit 0
}

run_bats() {
  local start_time 
  echo -e "Running units: ${*}\n"
  start_time=$(date +%s.%N)
  CLOUD=${CLOUD} GIT_COMMIT=${GIT_COMMIT} bats "${BATS_OPTIONS}" "${@}" || exit 1
  local end_time=$(date +%s.%N)
  local duration=$(echo "${end_time} - ${start_time}" | bc)
  echo -e "Time taken: ${duration} secs\n"
}

# run-checks runs a collection checks
run_checks() {
  local CLOUD_FILES=(
    "${UNITS}/common/bootstrap.sh"
    "${UNITS}/common/platform.sh"
    "${UNITS}/${CLUSTER_TYPE}/registration.sh"
    "${UNITS}/common/applicationsets.sh"
    "${UNITS}/common/priorityclasses.sh"
    "${UNITS}/${CLUSTER_TYPE}/tenant-namespace.sh"
    "${UNITS}/${CLUSTER_TYPE}/tenant-helm-apps.sh"
    "${UNITS}/${CLUSTER_TYPE}/tenant-helm-apps-values.sh"
    "${UNITS}/${CLUSTER_TYPE}/kyverno.sh"
    "${UNITS}/${CLUSTER_TYPE}/cilium.sh"
    "${UNITS}/common/cert-manager.sh"
  )

  # Run in the installation
  run_bats "${UNITS}/setup.sh"
  if [[ -n ${CLOUD}   ]]; then
    for x in "${CLOUD_FILES[@]}"; do
      if [[ -f ${x}   ]]; then
        run_bats "${x}" || exit 1
      fi
    done
  fi
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    --cloud)
      CLOUD="${2}"
      shift 2
      ;;
    --cluster-type)
      CLUSTER_TYPE="${2}"
      shift 2
      ;;
    --help)
      usage
      ;;
    *)
      usage "Unknown argument: ${1}"
      ;;
  esac
done

if [[ ${CLOUD} == "aws" ]] || [[ ${CLOUD} == "kind" ]]; then
  echo "Running checks for: ${CLOUD} ${CLUSTER_TYPE}"
else
  usage "Unknown cloud: ${CLOUD}"
fi

if [[ ${CLUSTER_TYPE} == "standalone" ]] || [[ ${CLUSTER_TYPE} == "hub" ]]; then
  echo "Running checks for: ${CLOUD} ${CLUSTER_TYPE}"
else
  usage "Unknown cluster type: ${CLUSTER_TYPE}"
fi

run_checks
