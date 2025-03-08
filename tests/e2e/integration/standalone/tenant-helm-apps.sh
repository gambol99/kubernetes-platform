# Description: the purpose of these checks to ensure the tenant helm application are working as expected

load ../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}

@test "Ensure the tenant helm application set is installed" {
  kubectl_argocd "get applicationset tenant-apps-helm"
}

@test "Ensure the tenant helm application set is healthy" {
  kubectl_argocd "get applicationset tenant-apps-helm -o yaml | yq .status.conditions[0].type | grep -i ErrorOccurred"
  kubectl_argocd "get applicationset tenant-apps-helm -o yaml | yq .status.conditions[0].status | grep -i False"
}

@test "Ensure the tenant application has been created" {
  kubectl_argocd "get application tenant-helm-hello-world-helm-dev"
}

@test "Ensure the tenant application is healthy" {
  kubectl_argocd "get application tenant-helm-hello-world-helm-dev -o yaml | yq .status.health.status | grep -i healthy"
}

@test "Ensure the tenant application has the correct number of resources" {
  kubectl_argocd "get application tenant-helm-hello-world-helm-dev -o yaml | yq .status.resources | grep -i 'hello-world-helm'"
}

@test "Ensure the tenant application namespace was provisioned" {
  kubectl "get namespace hello-world-helm"
  kubectl "get namespace hello-world-helm -o yaml | yq .metadata.labels | grep -i 'platform.local/namespace: tenant'"
}

@test "Ensure the tenant application namespace is deployed" {
  kubectl "get deployment hello-world-helm -n hello-world-helm"
  kubectl "get pod -l app.kubernetes.io/name=hello-world --no-headers -n hello-world-helm | grep hello"
}
