# Pod Security Policies

Pod Security Admission (PSA) is a built-in admission controller in Kubernetes that enforces Pod Security Standards (PSS) at the namespace level. PSA helps ensure that pods running in your cluster adhere to security best practices by applying predefined security policies.

### Pod Security Standards

Kubernetes defines three levels of Pod Security Standards:

- **Privileged**: Provides the least restrictive policies, allowing all capabilities and access.
- **Baseline**: Provides a reasonable set of restrictions that prevent known privilege escalation and the most common security risks.
- **Restricted**: Provides the most restrictive policies, enforcing best practices for security.

### Namespace Policies

By default, all namespaces, including system namespaces, will use the Baseline policy. However, you can change the policy for a specific namespace by setting the `pod-security` field in the namespace options. Note, as of now ONLY system application can change the PSA level i.e those deployed by `workloads/system`; standard tenant application default to `baseline`.

Example:

```yaml
## For helm applications
helm: ...
## Namespace configuration
namespace:
  ## Override pod security policy for the namespace, default is Baseline
  pod_security: restricted
```

For kustomize applications, you can set the `pod-security` field in the namespace options.

Example:

```yaml
kustomize: {}
## Namespace configuration
namespace:
  ## Override pod security policy for the namespace, default is Baseline
  pod_security: restricted
```

Note for security reason all tenant applications MUST run using the baseline security policy, which cannot be changed. Only system applications can change their security posture.
