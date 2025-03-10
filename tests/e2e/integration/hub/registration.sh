# Description: the purpose of these checks to ensure the cluster is registered

load ../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}

@test "We should have a cluster registration applicationset" {
  kubectl_argocd "get applicationset system-registration"
}

@test "We should have a cluster registration applicationset with no errors" {
  kubectl_argocd "get applicationset system-registration -o yaml | yq .status.conditions[0].type | grep -i ErrorOccurred"
  kubectl_argocd "get applicationset system-registration -o yaml | yq .status.conditions[0].status | grep -i False"
}

@test "We should have a cluster registration applications" {
  kubectl_argocd "get application system-registration-hub"
  kubectl_argocd "get application system-registration-spoke"
}

@test "We should have a cluster registration application pointing at the correct git repository" {
  kubectl_argocd "get application system-registration-hub -o yaml | yq .spec.sources[0].repoURL | grep -i https://github.com/gambol99/kubernetes-platform"
  kubectl_argocd "get application system-registration-spoke -o yaml | yq .spec.sources[0].repoURL | grep -i https://github.com/gambol99/kubernetes-platform"
}

@test "We should have a cluster registration application pointing at the correct git branch" {
  kubectl_argocd "get application system-registration-hub -o yaml | yq .spec.sources[0].targetRevision | grep -i ."
  kubectl_argocd "get application system-registration-spoke -o yaml | yq .spec.sources[0].targetRevision | grep -i ."
}

@test "We should have a cluster registration application pointing at the correct cluster" {
  kubectl_argocd "get application system-registration-hub -o yaml | yq .spec.sources[0].helm.valueFiles[0] | grep -i '$values/release/hub/clusters'"
  kubectl_argocd "get application system-registration-spoke -o yaml | yq .spec.sources[0].helm.valueFiles[0] | grep -i '$values/release/hub/clusters'"
}

@test "We should have a healthy cluster registration application" {
  kubectl_argocd "get application system-registration-hub -o yaml | yq .status.health.status | grep -i healthy"
  kubectl_argocd "get application system-registration-spoke -o yaml | yq .status.health.status | grep -i healthy"
}

@test "We should have a cluster secret" {
  kubectl_argocd "get secret cluster-hub"
}

@test "We should have a cluster secret with a platform_repository annotation" {
  kubectl_argocd "get secret cluster-hub -o yaml | yq .metadata.annotations.platform_repository | grep -i https://github.com/gambol99/kubernetes-platform"
}

@test "We should have a cluster secret with a platform_revision annotation" {
  kubectl_argocd "get secret cluster-hub -o yaml | yq .metadata.annotations.platform_revision | grep -i ."
}

@test "We should have a cluster secret with a tenant repository annotation" {
  kubectl_argocd "get secret cluster-hub -o yaml | yq .metadata.annotations.tenant_repository | grep -i https://github.com/gambol99/kubernetes-platform"
}

@test "We should have a cluster secret with a tenant revision annotation" {
  kubectl_argocd "get secret cluster-hub -o yaml | yq .metadata.annotations.tenant_revision | grep -i ."
}

@test "We should have the expected labels on the cluster secret" {
  kubectl_argocd "get secret cluster-hub -o yaml | yq .metadata.labels | grep -i 'enable_core: \"true\"'"  
  kubectl_argocd "get secret cluster-hub -o yaml | yq .metadata.labels | grep -i 'enable_kyverno: \"true\"'"
  kubectl_argocd "get secret cluster-hub -o yaml | yq .metadata.labels | grep -i 'cluster_type: hub'"
  kubectl_argocd "get secret cluster-hub -o yaml | yq .metadata.labels | grep -i 'cluster_name: hub'"
  kubectl_argocd "get secret cluster-hub -o yaml | yq .metadata.labels | grep -i 'environment: release'"
  kubectl_argocd "get secret cluster-hub -o yaml | yq .metadata.labels | grep -i 'argocd.argoproj.io/secret-type: cluster'"
}