# Description: Validating the cert-manager installation

load ../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch "${BATS_PARENT_TMPNAME}.skip"
}

@test "We should have a cert-manager application" {
  kubectl "get namespace cert-manager"
}

@test "We should have a cert-manager pods running" {
  retry 20 "kubectl wait --for=condition=available --timeout=60s deployment/cert-manager -n cert-manager"
  retry 20 "kubectl wait --for=condition=available --timeout=60s deployment/cert-manager-cainjector -n cert-manager"
  retry 20 "kubectl wait --for=condition=available --timeout=60s deployment/cert-manager-webhook -n cert-manager"
}

@test "We should have a clusterissuer for self signed certificate" {
  retry 20 "kubectl get clusterissuer selfsigned-issuer"
}
