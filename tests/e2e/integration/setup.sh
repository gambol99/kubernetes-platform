# Description:
#   This script is used to setup the test environment for the kubernetes platform
#   It will create a kind cluster and install the kubernetes platform

load ../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}

@test "Ensure we have the argocd namespace" {
  run kubectl get namespace argocd
}

@test "Ensure we have the argocd application pods" {
  run kubectl get pods -n argocd
}

@test "Ensure we have the argocd application service" {
  run kubectl get service -n argocd
}

@test "Ensure all the services are ready" {
  run kubectl -n argocd wait --for=condition=Ready pods --all -l app.kubernetes.io/name=argocd-repo-server --timeout=90s
}