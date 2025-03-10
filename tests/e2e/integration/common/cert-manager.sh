# Description: Validating the cert-manager installation

load ../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch "${BATS_PARENT_TMPNAME}.skip"
}

@test "Ensure the cert-manager application is installed" {
  kubectl "get namespace cert-manager"
}

@test "We should have a private issuer created" {
  kubectl "get issuer selfsigned-issuer -n cert-manager"
}
