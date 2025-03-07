#!/usr/bin/env bash
#
## This script is used to run the check suite for the kubernetes platform
## 

BATS_OPTIONS=${BATS_OPTIONS:-""}
CLOUD="kind"
UNITS="tests/e2e/integration"

usage() {
  cat << EOF
Usage: $0 [options]

--cloud <NAME>         Cloud provider name to run against (defaults: ${CLOUD})
--help                 Display this help message

EOF
  if [[ -n ${*}   ]]; then
    echo "Error: ${1}"
    exit 1
  fi

  exit 0
}

run_bats() {
  echo -e "Running units: ${*}\n"
  CLOUD=${CLOUD} bats ${BATS_OPTIONS} ${@} || exit 1
}

# run-checks runs a collection checks
run_checks() {
  local CLOUD_FILES=(
    "${UNITS}/argocd.sh"
    "${UNITS}/bootstrap.sh"
    "${UNITS}/platform.sh"
    "${UNITS}/registration.sh"
    "${UNITS}/applicationsets.sh"
    "${UNITS}/kyverno.sh"
    "${UNITS}/tenant-helm.sh"
  )

  # Run in the installation
  run_bats "${UNITS}/setup.sh"
  if [[ -n ${CLOUD}   ]]; then
    echo -e "Running suite on: ${CLOUD^^}\n"
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
    --help)
      usage
      ;;
    *)
      usage "Unknown argument: ${1}"
      ;;
  esac
done

[[ ${CLOUD} == "aws" ]] || [[ ${CLOUD} == "kind" ]] || usage "Unknown cloud: ${CLOUD}"

run_checks
