load ../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}

@test "We should have a platform application" {
  kubectl_argocd "get application platform"
}

@test "We should have a healthy platform" {
  kubectl_argocd "get application platform -o yaml | yq .status.health.status | grep -i healthy"
}

@test "We should have a platform in sync" {
  kubectl_argocd "get application platform -o yaml | yq .status.sync.status | grep -i synced"
}
