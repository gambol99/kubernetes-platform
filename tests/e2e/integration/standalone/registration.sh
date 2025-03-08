# Description: the purpose of these checks to ensure the cluster is registered

load ../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}

@test "Ensure the cluster registration application has been provisioned" {
  kubectl_argocd "get application system-registration"
}

@test "Ensure the cluster registration application pointing at the correct git repository" {
  kubectl_argocd "get application system-registration -o yaml | yq .spec.sources[0].repoURL | grep -i https://github.com/gambol99/kubernetes-platform"
}

@test "Ensure the cluster registration application pointing at the correct git branch" {
  kubectl_argocd "get application system-registration -o yaml | yq .spec.sources[0].targetRevision | grep -i ."
}

@test "Ensure the cluster registration application is pointing at the correct cluster" {
  kubectl_argocd "get application system-registration -o yaml | yq .spec.sources[0].helm.valueFiles[0] | grep -i '$values/release/standalone/clusters/dev.yaml'"
}

@test "Ensure the cluster registration application is healthy" {
  kubectl_argocd "get application system-registration -o yaml | yq .status.health.status | grep -i healthy"
}

@test "Ensure the cluster secret has been created" {
  kubectl_argocd "get secret cluster-dev"
}

@test "Ensure the cluster secret has a platform_repository annotation" {
  kubectl_argocd "get secret cluster-dev -o yaml | yq .metadata.annotations.platform_repository | grep -i https://github.com/gambol99/kubernetes-platform"
}

@test "Ensure the cluster secret has a platform_revision annotation" {
  kubectl_argocd "get secret cluster-dev -o yaml | yq .metadata.annotations.platform_revision | grep -i ."
}

@test "Ensure the cluster secret has a tenant repository annotation" {
  kubectl_argocd "get secret cluster-dev -o yaml | yq .metadata.annotations.tenant_repository | grep -i https://github.com/gambol99/kubernetes-platform"
}

@test "Ensure the cluster secret has a tenant revision annotation" {
  kubectl_argocd "get secret cluster-dev -o yaml | yq .metadata.annotations.tenant_revision | grep -i ."
}

@test "Ensure we have the expected labels on the cluster secret" {
  kubectl_argocd "get secret cluster-dev -o yaml | yq .metadata.labels | grep -i 'enable_core: \"true\"'"  
  kubectl_argocd "get secret cluster-dev -o yaml | yq .metadata.labels | grep -i 'enable_kyverno: \"true\"'"
  kubectl_argocd "get secret cluster-dev -o yaml | yq .metadata.labels | grep -i 'cluster_type: standalone'"
  kubectl_argocd "get secret cluster-dev -o yaml | yq .metadata.labels | grep -i 'cluster_name: dev'"
  kubectl_argocd "get secret cluster-dev -o yaml | yq .metadata.labels | grep -i 'environment: release'"
  kubectl_argocd "get secret cluster-dev -o yaml | yq .metadata.labels | grep -i 'argocd.argoproj.io/secret-type: cluster'"
}