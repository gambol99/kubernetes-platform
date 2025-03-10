# Description: these tests verify the tenant ingress controller is correctly configured 

load ../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch "${BATS_PARENT_TMPNAME}.skip"
}

@test "We should have a ingress-system namespace" { 
  kubectl "get namespace ingress-system"
}

@test "We should have a tenant system label on the ingress-system namespace" {
  kubectl "get namespace ingress-system -o yaml | yq .metadata.labels | grep -i 'platform.local/namespace-type: tenant-system'"
}

@test "We should have a ingress-nginx-controller deployment" {
  kubectl "get deployment ingress-system-ingress-nginx-controller -n ingress-system"
}
