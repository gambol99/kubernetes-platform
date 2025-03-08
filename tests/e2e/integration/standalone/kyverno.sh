# Description: used to check if kyverno is installed and configured correctly

load ../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}

@test "Ensure the Kyverno application is installed" {
  runit "kubectl get application system-kyverno-dev -n argocd"
}

@test "Ensure the Kyverno application is healthy" {
  retry 20 "kubectl get application system-kyverno-dev -n argocd -o yaml | yq .status.health.status | grep -i healthy" || {
    echo "Application is not healthy, checking pod logs"
    kubectl -n argocd get application system-kyverno-dev -o yaml
    return 1
  }
}

@test "Ensure the Kyverno system is installed" {
  kubectl "get namespace kyverno-system"
}

@test "Ensure the Kyverno deployment is installed" {
  kubectl "get deployment kyverno-admission-controller -n kyverno-system"
  kubectl "get deployment kyverno-background-controller -n kyverno-system"
  kubectl "get deployment kyverno-cleanup-controller -n kyverno-system"
  kubectl "get deployment kyverno-reports-controller -n kyverno-system"
}

@test "Ensure the Kyverno validating webhook is installed" {
  NAMES=(
    ingress-system-ingress-nginx-admission
    kyverno-cleanup-validating-webhook-cfg
    kyverno-exception-validating-webhook-cfg
    kyverno-global-context-validating-webhook-cfg
    kyverno-policy-validating-webhook-cfg
    kyverno-resource-validating-webhook-cfg
    kyverno-ttl-validating-webhook-cfg
  )
  for NAME in "${NAMES[@]}"; do
    kubectl "get validatingwebhookconfiguration ${NAME}"
  done
}

@test "Ensure the Kyverno kustomize application is installed" {
  kubectl "get application system-kust-kyverno-dev -n argocd"
}

@test "Ensure the Kyverno policies are installed" {
  POLICIES=(
    deny-cap-net-raw
    deny-default-namespace
    deny-empty-ingress-host
  )
  for POLICY in "${POLICIES[@]}"; do
    kubectl "get clusterpolicy ${POLICY}"
  done
}
