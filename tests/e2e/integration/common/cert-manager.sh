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

@test "We should have a private issuer created" {
  kubectl "get clusterissuer selfsigned-issuer -n cert-manager"
}
