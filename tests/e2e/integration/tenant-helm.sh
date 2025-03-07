# Description: the purpose of these checks to ensure the tenant helm application are working as expected

load ../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}

@test "Ensure the tenant helm application set is installed" {
  runit "kubectl get applicationset tenant-apps-helm -n argocd"
}

@test "Ensure the tenant helm application set is healthy" {
  runit "kubectl get applicationset tenant-apps-helm -n argocd -o yaml | yq .status.conditions[0].type | grep -i ErrorOccurred"
  runit "kubectl get applicationset tenant-apps-helm -n argocd -o yaml | yq .status.conditions[0].status | grep -i False"
}

@test "Ensure the tenant application has been created" {
  runit "kubectl get application tenant-helm-hello-world-helm-dev -n argocd"
}

@test "Ensure the tenant application is healthy" {
  runit "kubectl get application tenant-helm-hello-world-helm-dev -n argocd -o yaml | yq .status.health.status | grep -i healthy"
}

@test "Ensure the tenant application has the correct number of resources" {
  runit "kubectl get application tenant-helm-hello-world-helm-dev -n argocd -o yaml | yq .status.resources | grep -i 'hello-world-helm'"
}
