# :material-package-variant-closed-plus: Tenant Application Namespaces

## :octicons-stack-24: Overview

When deploying applications in either `workloads/applications/` or `workloads/system/`, namespaces provisioned will automatically receive a default bundle of Kubernetes resources. This standardizes namespace configuration and security across the platform. The default resources include network policies, RBAC resources, and ingress rules, ensure consistent security controls and access patterns.

You can find the default manifests [here](https://github.com/gambol99/kubernetes-platform/tree/main/apps/tenant/namespace)
