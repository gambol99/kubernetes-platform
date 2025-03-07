# Description: the purpose of these checks to ensure the cluster is registered

load ../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch ${BATS_PARENT_TMPNAME}.skip
}

@test "Ensure the cluster registration application has been provisioned" {
  run kubectl -n argocd get application system-registration
}

@test "Ensure the cluster registration application pointing at the correct git repository" {
  runit "kubectl -n argocd get application system-registration -o yaml | yq .spec.sources[0].repoURL | grep -i https://github.com/gambol99/kubernetes-platform"
}

@test "Ensure the cluster registration application pointing at the correct git branch" {
  runit "kubectl -n argocd get application system-registration -o yaml | yq .spec.sources[0].targetRevision | grep -i main"
}

@test "Ensure the cluster registration application is pointing at the correct cluster" {
  runit "kubectl -n argocd get application system-registration -o yaml | yq .spec.sources[0].helm.valueFiles[0] | grep -i '$values/release/standalone/clusters/dev.yaml'"
}

@test "Ensure the cluster registration application is healthy" {
  runit "kubectl -n argocd get application system-registration -o yaml | yq .status.health.status | grep -i healthy"
}

@test "Ensure the cluster secret has been created" {
  runit "kubectl get secret cluster-dev -n argocd"
}

@test "Ensure the cluster secret has a platform_repository annotation" {
  runit "kubectl get secret cluster-dev -n argocd -o yaml | yq .metadata.annotations.platform_repository | grep -i https://github.com/gambol99/kubernetes-platform"
}

@test "Ensure the cluster secret has a platform_revision annotation" {
  runit "kubectl get secret cluster-dev -n argocd -o yaml | yq .metadata.annotations.platform_revision | grep -i main"
}

@test "Ensure the cluster secret has a tenant repository annotation" {
  runit "kubectl get secret cluster-dev -n argocd -o yaml | yq .metadata.annotations.tenant_repository | grep -i https://github.com/gambol99/kubernetes-platform"
}

@test "Ensure the cluster secret has a tenant revision annotation" {
  runit "kubectl get secret cluster-dev -n argocd -o yaml | yq .metadata.annotations.tenant_revision | grep -i main"
}

@test "Ensure we have the expected labels on the cluster secret" {
  runit "kubectl get secret cluster-dev -n argocd -o yaml | yq .metadata.labels | grep -i 'enable_core: \"true\"'"  
  runit "kubectl get secret cluster-dev -n argocd -o yaml | yq .metadata.labels | grep -i 'enable_kyverno: \"true\"'"
  runit "kubectl get secret cluster-dev -n argocd -o yaml | yq .metadata.labels | grep -i 'cluster_type: standalone'"
  runit "kubectl get secret cluster-dev -n argocd -o yaml | yq .metadata.labels | grep -i 'cluster_name: dev'"
  runit "kubectl get secret cluster-dev -n argocd -o yaml | yq .metadata.labels | grep -i 'environment: release'"
  runit "kubectl get secret cluster-dev -n argocd -o yaml | yq .metadata.labels | grep -i 'argocd.argoproj.io/secret-type: cluster'"
}