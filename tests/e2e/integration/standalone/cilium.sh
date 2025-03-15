## Description: This script contains the common functions for the cilium tests

load ../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch "${BATS_PARENT_TMPNAME}.skip"
}

@test "We should have an cilium application in argocd namespace" {
  retry 20 "kubectl get application -n argocd -l app.kubernetes.io/name=cilium | grep -q 'system-cilium'"
}

@test "We should have a cilium namespace" {
  kubectl "get namespace cilium-system"
}

@test "We should have cilium custom resources configured" {
  kubectl "get crd | grep -i cilium"
}

@test "We should have a cilium deployments" {
  DEPLOYMENTS=(
    cilium-operator
    hubble-relay
    hubble-ui
  )

  for DEPLOYMENT in "${DEPLOYMENTS[@]}"; do
    kubectl "get deployment -n cilium-system ${DEPLOYMENT}"
  done
}

@test "We should have running cilium pods" {
  PODS=(
    cilium-envoy
    cilium-agent
    cilium-operator
    hubble-relay
    hubble-ui
  )

  for POD in "${PODS[@]}"; do
    kubectl "get pod -n cilium-system -l app.kubernetes.io/name=${POD} | grep -q 'Running'"
  done
}
