## Description: used to test the storage classes are provisioned correctly 

load ../../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch "${BATS_PARENT_TMPNAME}.skip"
}

@test "We should have a storage class called gp3" {
  runit "kubectl get storageclass gp3"
}

@test "We should have defined the gp3 storage class as the default storage class" {
  runit "kubectl get storageclass | grep -q 'gp3.*(default)'"
}