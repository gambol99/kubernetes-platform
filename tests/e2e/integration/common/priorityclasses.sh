# Description: the purpose of these checks to ensure the priority classes are created

load ../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}

@test "We should have a priority classes" {
  kubectl "get priorityclasses.scheduling.k8s.io platform-critical"
}