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

@test "We should have a tenant-helm-helm-app-dev application" {
  kubectl_argocd "get application -l app.kubernetes.io/name=helm-app"
}

@test "We should have a healthy tenant application" {
  kubectl_argocd "get application -l app.kubernetes.io/name=helm-app -o yaml | yq .items[0].status.health.status | grep -i healthy"
}

@test "We should have a helm-app application" {
  kubectl_argocd "get application -l app.kubernetes.io/name=helm-app -o yaml | yq .items[0].status.resources | grep -i 'helm-app'"
}

@test "We should have a helm-app namespace" {
  kubectl "get namespace helm-app"
  kubectl "get namespace helm-app -o yaml | yq .metadata.labels | grep -i 'platform.local/namespace: tenant'"
}

@test "We should have a label indicating a tenant application type" {
  kubectl "get namespace helm-app -o yaml | yq .metadata.labels | grep -i 'platform.local/namespace-type: tenant-application'"
}

@test "We should have a helm-app deployment" {
  kubectl "get deployment helm-app-hello-world -n helm-app"
  kubectl "get pod -l app.kubernetes.io/name=hello-world --no-headers -n helm-app | grep hello"
}
