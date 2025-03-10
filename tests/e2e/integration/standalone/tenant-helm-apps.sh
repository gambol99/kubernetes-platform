# Description: the purpose of these checks to ensure the tenant helm application are working as expected

load ../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}

@test "We should have a tenant helm application set" {
  kubectl_argocd "get applicationset tenant-apps-helm"
}

@test "We should have a healthy tenant helm application set" {
  kubectl_argocd "get applicationset tenant-apps-helm -o yaml | yq .status.conditions[0].type | grep -i ErrorOccurred"
  kubectl_argocd "get applicationset tenant-apps-helm -o yaml | yq .status.conditions[0].status | grep -i False"
}

@test "We should have a tenant-helm-hello-world-helm-dev application" {
  kubectl_argocd "get application tenant-helm-hello-world-helm-dev"
}

@test "We should have a healthy tenant application" {
  kubectl_argocd "get application tenant-helm-hello-world-helm-dev -o yaml | yq .status.health.status | grep -i healthy"
}

@test "We should have a hello-world-helm application" {
  kubectl_argocd "get application tenant-helm-hello-world-helm-dev -o yaml | yq .status.resources | grep -i 'hello-world-helm'"
}

@test "We should have a hello-world-helm namespace" {
  kubectl "get namespace hello-world-helm"
  kubectl "get namespace hello-world-helm -o yaml | yq .metadata.labels | grep -i 'platform.local/namespace: tenant'"
}

@test "We should have a label indicating a tenant application type" {
  kubectl "get namespace hello-world-helm -o yaml | yq .metadata.labels | grep -i 'platform.local/namespace-type: tenant-application'"
}

@test "We should have a hello-world-helm deployment" {
  kubectl "get deployment hello-world-helm -n hello-world-helm"
  kubectl "get pod -l app.kubernetes.io/name=hello-world --no-headers -n hello-world-helm | grep hello"
}
