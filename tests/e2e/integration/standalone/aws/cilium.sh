## Description: used to test the cilium is provisioned correctly

load ../../../lib/helper

setup() {
  [[ ! -f ${BATS_PARENT_TMPNAME}.skip ]] || skip "skip remaining tests"
}

teardown() {
  [[ -n $BATS_TEST_COMPLETED   ]] || touch "${BATS_PARENT_TMPNAME}.skip"
}

@test "We should be able to create a network policy to filter traffic" {
  # Delete any existing cilium-test namespace
  kubectl "delete namespace cilium-test || true"
  # Create test namespace
  kubectl "create namespace cilium-test"

  # Deploy test pods
  kubectl "run client --image=busybox:1.35.0 -n cilium-test -- sleep 3600"
  kubectl "run server --image=nginx:1.26.3-otel -n cilium-test"

  # Wait for pods to be ready
  kubectl "get pod -n cilium-test client | grep -q Running"
  kubectl "get pod -n cilium-test server | grep -q Running"

  # Test connectivity before policy
  kubectl "expose -n cilium-test pod server --port=80"
  kubectl "exec -n cilium-test client -- wget --spider --timeout=1 server"

  # Apply network policy
  cat <<EOF > ${BATS_TMPDIR}/resource.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-policy
spec:
  podSelector:
    matchLabels:
      run: server
  policyTypes:
  - Ingress
  ingress: []
EOF
  kubectl "apply -f ${BATS_TMPDIR}/resource.yaml"

  # Test that connection is now blocked
  kubectl "exec -n cilium-test client -- wget --spider --timeout=1 server 2>&1 | grep -q 'download timed out"

  # Cleanup
  kubectl "delete namespace cilium-test --wait=false"
}

@test "We should be able to filter traffic based on L7 rules" {
  # Delete any existing cilium-l7-test namespace
  kubectl "delete namespace cilium-l7-test || true"
  # Create test namespace
  kubectl "create namespace cilium-l7-test"

  # Deploy test pods
  kubectl "run client --image=curlimages/curl:8.12.1 -n cilium-l7-test -- sleep 3600"
  kubectl "run server --image=cilium/echoserver:1.10.3 -n cilium-l7-test"

  # Wait for pods to be ready
  retry 10 "kubectl get pod -n cilium-l7-test client | grep -q Running"
  retry 10 "kubectl get pod -n cilium-l7-test server | grep -q Running"

  # Apply CiliumNetworkPolicy with L7 rules
  cat <<EOF > "${BATS_TMPDIR}/resource.yaml"
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: l7-policy
  namespace: cilium-l7-test
spec:
  endpointSelector:
    matchLabels:
      run: server
  ingress:
  - fromEndpoints:
    - matchLabels:
        run: client
    toPorts:
    - ports:
      - port: "80"
        protocol: TCP
      rules:
        http:
        - method: "GET"
          path: "/get"
EOF
  kubectl "apply -f ${BATS_TMPDIR}/resource.yaml"
  # Wait for policy to be applied
  sleep 2
  # Expose server pod
  kubectl "expose -n cilium-l7-test pod server --port=80"
  # Test allowed path
  kubectl "exec -n cilium-l7-test client -- curl --connect-timeout 1 -s -o /dev/null -w '%{http_code}' server/get | grep -q 200"
  # Test blocked path
  kubectl "exec -n cilium-l7-test client -- curl --connect-timeout 1 -s -o /dev/null -w '%{http_code}' server/post | grep -q 403"
  # Cleanup
  kubectl "delete namespace cilium-l7-test --wait=false"
}

@test "We should be able to monitor traffic with hubble" {
  # Create test namespace and pods
  kubectl "delete namespace hubble-test || true"
  kubectl "create namespace hubble-test"
  kubectl "run client --image=busybox:1.35.0 -n hubble-test -- sleep 3600"
  kubectl "run server --image=nginx:1.26.3-otel -n hubble-test"

  # Wait for pods to be ready
  kubectl "get pod -n hubble-test client | grep -q Running"
  kubectl "get pod -n hubble-test server | grep -q Running"

  # Generate some traffic
  kubectl "expose -n hubble-test pod server --port=80"
  kubectl "exec -n hubble-test client -- wget --spider --timeout=1 server"

  # Check if Hubble observed the traffic
  kubectl "exec -n cilium-system deployment/hubble-relay -- hubble observe --last 10"

  # Cleanup
  kubectl "delete namespace hubble-test --wait=false"
}
