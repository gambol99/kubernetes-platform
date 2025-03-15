# Description: the purpose of these checks is to validate the helm.helm_values is working as expected

load ../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}


@test "We should a custom helm application" {
  kubectl "get application -n argocd -l app.kubernetes.io/name=custom-helm-values | grep -q 'Healthy'"
}

@test "We should have a synced custom helm application" {
  kubectl "get application -n argocd -l app.kubernetes.io/name=custom-helm-values | grep -q 'Synced'"
}

@test "We should have a service account with attributes from the parameters" {
  kubectl "get serviceaccount -n custom-helm-values custom-helm-values-hello-world"
  kubectl "get serviceaccount -n custom-helm-values custom-helm-values-hello-world -o yaml | yq .metadata.annotations.by_metadata | grep -i kind"
  kubectl "get serviceaccount -n custom-helm-values custom-helm-values-hello-world -o yaml | yq .metadata.annotations.by_value | grep -i test_value"
}
