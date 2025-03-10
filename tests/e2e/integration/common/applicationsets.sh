# Description: the purpose of these tests are a light weight check all the expected application sets are running 

load ../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}

@test "We should have a system helm application set" {
  kubectl_argocd "get appset system-helm"
}

@test "We should have a system kustomize application set" {
  kubectl_argocd "get appset system-kustomize"
}

@test "We should have a tenant apps helm application set" {
  kubectl_argocd "get appset tenant-apps-helm"
}

@test "We should have a tenant system helm application set" {
  kubectl_argocd "get appset tenant-apps-helm"
}

@test "We should have a tenant system kustomize application set" {
  kubectl_argocd "get appset tenant-apps-kustomize"
}