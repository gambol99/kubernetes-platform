# :material-application-cog: Tenant ArgoCD Application Sets

All tenant application sets can be found in the [apps/tenant](https://github.com/gambol99/kubernetes-platform/tree/main/apps/tenant) directory. Similar to the system application sets, these are responsible for sourcing the tenant application definitions and applying kustomize patches where required. Indeed the application definition for applications are almost identical.

## :material-projector-screen-outline: ArgoCD Projects

While the bulk of the system applications run under the `default` ArgoCD project, the tenant applications run under a projects `tenat-applications` and `tenant-system` depending on whether they are system or standard applications. This used to place restrictions on the namespaces a tenant application can deploy, as well as resources the applications can provision.

## :material-application-array-outline: Tenant Helm Application Set

The [tenant helm application](https://github.com/gambol99/kubernetes-platform/blob/main/apps/tenant/apps-helm.yaml) set is similar to the system helm application set, but is responsible for installing the tenant applications. The tenant applications are sourced from the tenant repository.

Applications for tenants can be deployed using a GitOps approach directly from the tenant repository. The workloads folder contains two main directories:

:material-arrow-right-bold-circle-outline: `workloads/applications` - Contains standard application definitions that run under the tenant's ArgoCD project with regular permissions

:material-arrow-right-bold-circle-outline: `workloads/system` - Contains system-level application definitions that run under a privileged ArgoCD project with elevated permissions

By simply adding Helm charts configurations into the appropriate directory structure, applications can be:

- Easily deployed to the cluster
- Upgraded through GitOps workflows
- Promoted between environments in a controlled manner

This separation of applications and system components allows for proper access control while maintaining a simple deployment model.

### :material-square-rounded-badge-outline: Helm Applications

You can deploy using a helm chart, by adding a `CLUSTER_NAME.yaml`.

1. Create a folder (by default this becomes the namespace)
2. Add a `CLUSTER_NAME.yaml` file

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

## Sync Options
sync:
  # (Optional) The phase to use for the deployment, used to determine the order of the deployment.
  phase: primary|secondary
  # (Optional) The duration to use for the deployment.
  duration: 30s
  # (Optional) The max duration to use for the deployment.
  max_duration: 5m
```

In order to use helm values, you need to create a `values.yaml` file.

1. For the helm values, create a folder called `values` inside the folder you created in step 1.
2. Add a `all.yaml` file to the values folder, which will be used to deploy the application.

## :material-application-array-outline: Tenant Kustomize Application Set

The [tenant kustomize application](https://github.com/gambol99/kubernetes-platform/blob/main/apps/tenant/apps-kustomize.yaml) set is responsible for provisioning any kustomize related functionality from the tenant. The application set use's a [git generator](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Git/) to source all the `kustomize.yml` from the [workloads](

Kustomize applications are defined in a similar manner to helm applications, with the following fields:

```YAML
---
kustomize:
  # (Required) The path to the kustomize base.
  path: kustomize
  # (Optional) Override the namespace to use for the deployment.
  namespace: override-namespace
  # (Optional) Patches to apply to the deployment.
  patches:
    - target:
        kind: Deployment
        name: frontend
      patch:
        - op: replace
          path: /spec/template/spec/containers/0/image
          ## This value is looked from the cluster definition.
          value: metadata.annotations.image
          ## This is the default value to use if the value is not found.
          default: nginx:1.21.3
        - op: replace
          path: /spec/template/spec/containers/0/version
          ## This value is looked from the cluster definition.
          value: metadata.annotations.version
          ## This is the default value to use if the value is not found.
          default: "1.21.3"
```

## :material-application-array-outline: Tenant System Application Sets:

The platform will also deploy an additional applications for tenant system applications i.e. applications created in the `workspace/system` folder. These applications are deployed under the `tenant-system` ArgoCD project, which has elevated permissions. Note, these application sets are identical the above but are deployed under a different project, the only reason they are duplicated is at present ArgoCD does not permit to template the project name.

:material-arrow-right-bold-circle-outline: [tenant-system-helm](https://github.com/gambol99/kubernetes-platform/blob/main/apps/tenant/system-helm.yaml) - Deploys system applications from the tenant repository.

:material-arrow-right-bold-circle-outline: [tenant-system-kustomize](https://github.com/gambol99/kubernetes-platform/blob/main/apps/tenant/tenant-system-kustomize.yaml) - Deploys system applications from the tenant repository using kustomize.
