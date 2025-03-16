# :material-application-cog: Tenant System Applications

!!! note "Note"

    Please refer to the [architectural overview](../../architecture/overview.md) for an understanding on tenant and platform repositories

System applications deployed under `workloads/system/` have elevated privileges compared to regular applications. These system-level applications:

- Can deploy cluster-scoped resources (ClusterRoles, CustomResourceDefinitions, etc.)
- Run under a privileged ArgoCD project with higher permissions
- Are typically used for infrastructure and platform components
- Have access beyond namespace boundaries

This higher privilege level allows system applications to:

- Install cluster-wide operators and controllers
- Configure cluster-level security policies
- Set up monitoring and logging infrastructure
- Deploy shared services used by multiple applications

## :material-hazard-lights: Usage Guidelines

!!! note "Note"

    System applications have elevated permissions and can affect the entire cluster. Use caution when deploying system applications to avoid unintended consequences.

When deploying system applications:

1. Only place applications that truly need cluster-wide access under `workloads/system/`
2. Regular applications should remain under `workloads/applications/` with standard namespace-scoped permissions
3. Follow the same deployment formats (Helm/Kustomize) as regular applications
4. Be cautious with elevated privileges to avoid unintended cluster-wide changes

The separation between system and regular applications helps maintain proper security boundaries while enabling necessary cluster-wide functionality.

## :material-cog-outline: Namespace Override

By default, applications are deployed into a namespace matching their folder name. However, system applications can override this default namespace using the `namespace` field:

### Helm Example

```yaml
helm:
  ## (Optional) The chart to use for the deployment.
  chart: ./charts/platform
  ## (Optional) The path inside a repository to the chart to use for the deployment.
  path: ./charts/platform
  ## (Required) The release name to use for the deployment.
  release_name: platform
  ## (Required) The version of the chart to use for the deployment.
  version: 0.1.0

namespace:
  ## Override the namespace
  name: kube-system
```
