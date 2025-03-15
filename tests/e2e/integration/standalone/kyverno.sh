# Description: used to check if kyverno is installed and configured correctly

load ../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch "${BATS_PARENT_TMPNAME}.skip"
}

@test "We should have a Kyverno application" {
  runit "kubectl get application system-kyverno-dev -n argocd"
}

@test "We should have a healthy Kyverno application" {
  retry 20 "kubectl get application system-kyverno-dev -n argocd -o yaml | yq .status.health.status | grep -i healthy" || {
    echo "Application is not healthy, checking pod logs"
    kubectl -n argocd get application system-kyverno-dev -o yaml
    return 1
  }
}

@test "We should have a kyverno-system namespace" {
  kubectl "get namespace kyverno-system"
}

@test "We should have a kyverno-system deployment" {
  kubectl "get deployment kyverno-admission-controller -n kyverno-system"
  kubectl "get deployment kyverno-background-controller -n kyverno-system"
  kubectl "get deployment kyverno-cleanup-controller -n kyverno-system"
  kubectl "get deployment kyverno-reports-controller -n kyverno-system"
}

@test "We should have a kyverno-system validating webhook" {
  NAMES=(
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

@test "We should have a Kyverno kustomize application" {
  kubectl "get application system-kust-kyverno-dev -n argocd"
}

@test "We should not be permitted to run anything in the default namespace" {
  kubectl "-n default run console --image=busybox:1.28.3 2>&1 | grep deny-default-namespace"
}

@test "We should not be permitted to use an image latest" {
  kubectl "-n default run console --image=busybox:latest 2>&1 | grep deny-latest-image"
}
