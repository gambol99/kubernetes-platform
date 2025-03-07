# Description: the purpose of these tests are a light weight check all the expected application sets are running 

load ../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}

@test "Ensure the system helm application set is provisioned" {
  run kubectl -n argocd get appset system-helm 
}

@test "Ensure the system kustomize application set is provisioned" {
  run kubectl -n argocd get appset system-kustomize
}

@test "Ensure the tenant apps helm application set is provisioned" {
  run kubectl -n argocd get appset tenant-apps-helm
}

@test "Ensure the tenant system helm application set is provisioned" {
  run kubectl -n argocd get appset system-apps-helm
}

@test "Ensure the tenant system kustomize application set is provisioned" {
  run kubectl -n argocd get appset system-apps-kustomize
}