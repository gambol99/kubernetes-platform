# Description: the purpose of these checks to ensure the tenant namespace is provisioned

load ../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
} 

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}

@test "Ensure the tenant namespace is provisioned" {
  kubectl "get namespace hello-world-helm"
}

@test "Ensure the default service account is provisioned" {
  kubectl "get serviceaccount namespace-admin -n hello-world-helm"
  kubectl "get rolebinding namespace-admin -n hello-world-helm"
}

@test "Ensure the default role is provisioned" {
  kubectl "get role namespace-admin -n hello-world-helm"
}

@test "Ensure the default role binding is provisioned" {
  kubectl "get rolebinding namespace-admin -n hello-world-helm"
}

@test "Ensure the network policies is provisioned" {
  POLICIES=(
    allow-cert-manager
    allow-prometheus
    default-deny
  )

  for policy in "${POLICIES[@]}"; do
    kubectl "get networkpolicy ${policy} -n hello-world-helm"
  done
}