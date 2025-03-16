# Description: the purpose of these checks is to validate the psa labels are applied to the tenant namespaces

load ../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}

@test "We should have a psa label on the tenant application namespaces" {
  kubectl "get namespace helm-app -o yaml | yq .metadata.labels | grep -q 'pod-security.kubernetes.io/enforce: baseline'"
}