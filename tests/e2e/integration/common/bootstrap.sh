load ../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}

@test "We should have a platform bootstrap application" {
  kubectl_argocd "get application bootstrap"
}

@test "We should have a healthy platform bootstrap" {
  kubectl_argocd "get application bootstrap -o yaml | yq .status.health.status | grep -i healthy"
}

@test "We should have a platform bootstrap in sync" {
  kubectl_argocd "get application bootstrap -o yaml | yq .status.sync.status | grep -i synced"
}

@test "We should be using the platform repository" {
  kubectl_argocd "get application bootstrap -o yaml | yq .spec.source.repoURL | grep -i kubernetes-platform"
}

@test "We should be applying the kustomze patches" {
  kubectl_argocd "get application bootstrap -o yaml | yq .spec.source.kustomize.patches[0].patch | grep kubernetes-platform" 
}