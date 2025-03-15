# Network Policies with Cilium

Here are some examples of network policies you can create with Cilium:

## Example 1: Allow All Traffic to a Specific Service

```yaml
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: "allow-all-to-service"
spec:
  endpointSelector:
    matchLabels:
      app: my-service
  ingress:
    - fromEntities:
        - all
```

## Example 2: Deny All Traffic Except from a Specific Namespace

```yaml
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: "deny-all-except-namespace"
spec:
  endpointSelector:
    matchLabels:
      app: my-service
  ingress:
    - fromEndpoints:
        - matchLabels:
            namespace: trusted-namespace
```

## Example 3: Allow HTTP Traffic to a Specific Path

```yaml
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: "allow-http-to-path"
spec:
  endpointSelector:
    matchLabels:
      app: my-service
  ingress:
    - toPorts:
        - ports:
            - port: "80"
              protocol: TCP
          rules:
            http:
              - method: "GET"
                path: "/allowed-path"
```

## Example 4: Deny All Traffic Except Specific HTTP Methods

```yaml
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: "deny-all-except-methods"
spec:
  endpointSelector:
    matchLabels:
      app: my-service
  ingress:
    - toPorts:
        - ports:
            - port: "80"
              protocol: TCP
          rules:
            http:
              - method: "GET"
              - method: "POST"
```
