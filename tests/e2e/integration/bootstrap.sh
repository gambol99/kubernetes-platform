load ../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}

@test "Ensure the platform bootstrap application has been provision" {
  run kubectl -n argocd get application bootstrap
}

@test "Ensure the platform bootstrap is healthy" {
  runit "kubectl -n argocd get application bootstrap -o yaml | yq .status.health.status | grep -i healthy"
}

@test "Ensure the platform bootstrap is in sync" {
  runit "kubectl -n argocd get application bootstrap -o yaml | yq .status.sync.status | grep -i synced"
}

@test "Ensure we are using the platform repository" {
  runit "kubectl -n argocd get application bootstrap -o yaml | yq .spec.source.repoURL | grep -i kubernetes-platform"
}

@test "Ensure we are applying the kustomze patches" {
  runit "kubectl -n argocd get application bootstrap -o yaml | yq .spec.source.kustomize.patches[0].patch | grep kubernetes-platform" 
}