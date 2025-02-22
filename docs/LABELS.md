# Resource Labeling

The following conventions are used to label resources in the cluster.

## Applications Labels

The following labels are used to identify applications in the cluster.

| Label | Description | Example |
|-------|-------------|---------|
| `app.kubernetes.io/name` | The name of the application | `my-app` |
| `app.kubernetes.io/instance` | The instance of the application | `my-app-1` |
| `app.kubernetes.io/part-of` | The parent application of the resource | `my-app` |
| `app.kubernetes.io/type` | The type of the application | `helm` |
| `app.kubernetes.io/version` | The version of the application | `1.0.0` |
| `app.kubernetes.io/component` | The component of the application | `api` |
| `app.kubernetes.io/managed-by` | The tool managing the application | `argocd` |

## Platform Labels

The following labels are used to identify platform resources in the cluster.

| Label | Description | Example |
|-------|-------------|---------|
| `platform.local/type` | The type of the platform resource | `tenant`,`platform` |
| `platform.local/environment` | The environment of the platform resource | `dev` |

## Tenant Labels

The following labels are used to identify tenant resources in the cluster.
