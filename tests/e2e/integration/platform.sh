load ../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}

@test "Ensure the platform application has been provision" {
  run kubectl -n argocd get application platform
}

@test "Ensure the platform is healthy" {
  runit "kubectl -n argocd get application platform -o yaml | yq .status.health.status | grep -i healthy"
}

@test "Ensure the platform is in sync" {
  runit "kubectl -n argocd get application platform -o yaml | yq .status.sync.status | grep -i synced"
}
