# Hub Registration Application Sets

These application sets are responsible for watching the cluster definitions from the tenant repository. The use the cluster definitions to provision a registration secret for each of the clusters which the hub is managing.

## How it works

Within the tenant repository, we have a `clusters` directory which contains the cluster definitions. Each cluster definition is a yaml file which contains the cluster configuration. For example:

```yaml
## Indicate the cluster is enabled
enabled: true
## The name of the tenant cluster
cluster_name: dev
## The cloud vendor to use for the tenant cluster
cloud_vendor: kind
## The environment to use for the tenant cluster
environment: release
## The repository containing the tenant configuration
tenant_repository: https://github.com/gambol99/kubernetes-platform.git
## The revision to use for the tenant repository
tenant_revision: main
## The path inside the tenant repository to use for the tenant cluster
tenant_path: release/hub
## The cost center to use for the tenant cluster
tenant_cost_center: "123456"
## The repository containing the platform configuration
platform_repository: https://github.com/gambol99/kubernetes-platform.git
## The revision to use for the platform repository
platform_revision: main
## The path to the kustomize overlay to use for the tenant cluster
platform_path: overlays/release
## We use labels to enable/disable features in the tenant cluster
labels:
  enable_cert_manager: "true"
  enable_ebs_driver: "true"
  enable_efs_driver: "true"
  enable_external_dns: "false"
  enable_external_secrets: "true"
  enable_kyverno: "true"
  enable_metrics_server: "false"
  enable_pod_identity: "true"
```

The application set uses a git generator to watch the cluster definitions from the tenant repository. Creating an application for each of the clusters found, and where `enabled` is set to `true`. We use the `charts/cluster-registration` chart to provision the registration secret for the cluster, for each of the clusters found.
