# Description: the purpose of these checks to ensure the tenant namespace is provisioned

load ../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}

@test "We should have a hello-world-helm namespace" {
  kubectl "get namespace helm-app"
}

@test "We should have a hello-world-helm service account" {
  kubectl "get serviceaccount namespace-admin -n helm-app"
}

@test "We should have a helm-app role binding" {
  kubectl "get rolebinding namespace-admin -n helm-app"
}

@test "We should have a helm-app role" {
  kubectl "get role namespace-admin -n helm-app"
}

@test "We should have a helm-app network policies" {
  POLICIES=(
    allow-cert-manager
    allow-prometheus
    default-deny
  )

  for policy in "${POLICIES[@]}"; do
    kubectl "get networkpolicy ${policy} -n helm-app"
  done
}
