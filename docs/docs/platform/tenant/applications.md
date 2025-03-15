# :material-application-cog: Tenant Applications

Applications for tenants can be deployed using a GitOps approach directly from the tenant repository. The workloads folder contains two main directories:

- **workloads/applications/** - Contains standard application definitions that run under the tenant's ArgoCD project with regular permissions
- **workloads/system/** - Contains system-level application definitions that run under a privileged ArgoCD project with elevated permissions

By simply adding Helm charts or Kustomize configurations into the appropriate directory structure, applications can be:

- Easily deployed to the cluster
- Upgraded through GitOps workflows
- Promoted between environments in a controlled manner

This separation of applications and system components allows for proper access control while maintaining a simple deployment model.

## :material-application-array-outline: Helm Applications

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
  ## (Optional) A collection of additional parameters - note these can reference metadata
  ## from the selected cluster definition.
  parameters:
    - name: serviceAccount.annotations.test
      value: default_value
    # Reference metadata from the cluster definition
    - name: serviceAccount.annotations.test2
      value: metadata.labels.cloud_vendor

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

## :material-application-array-outline: Helm with Multiple Charts

Similar to the helm deployment, create a folder for your deployments. Taking the example of two charts, frontend and backend, you would create a folder called `frontend` and `backend`.

1. Create a folder called for the application, e.g. `myapp`
2. Create two folders inside the `myapp` folder, `frontend` and `backend`
3. Add a `helm.yaml` file to the `frontend` folder.
4. You can same format as above for the `helm.yaml` file.
5. Add a `values` folder to the `frontend` folder, and add a `all.yaml` file to the values folder.
6. Add a `values` folder to the `backend` folder, and add a `all.yaml` file to the values folder.

## :material-application-array-outline: Kustomize

You can deploy using kustomize, by adding a `CLUSTER_NAME.yaml`.

1. Create a folder (by default this becomes the namespace)
2. Add the `CLUSTER_NAME.yaml` file

```yaml
kustomize:
  # (Required) The path to the kustomize base.
  path: kustomize
  # (Optional) Override the namespace to use for the deployment.
  namespace: override-namespace
  # (Required) Details the revision to point; this is a revision within those repository and
  # is used to control a point in time of the manifests.
  revision: <GIT+SHA>
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

Unlike Helm where versions are managed externally through chart repositories, Kustomize manifests are typically stored directly in your repository. While Kustomize overlays provide environment-specific customization, changes to shared base configurations could potentially affect all environments simultaneously.

To provide better control and safety, the `revision` field is used to pin Kustomize deployments to a specific Git commit or branch in the tenant repository. This allows you to:

- Make changes to manifests in the main branch without affecting production
- Control the rollout of changes across environments by updating revisions
- Roll back to previous versions by reverting to earlier commits
- Test changes in lower environments before promoting to production

**Example workflow:**

1. Develop and commit Kustomize changes to main branch
2. Test in dev environment by updating dev cluster's revision
3. Promote to staging/prod by updating their revisions after validation
4. Roll back if needed by reverting to previous commit SHA

## :material-application-array-outline: Kustomize with External Source

For teams that prefer to maintain their Kustomize manifests in a separate repository, you can reference external sources directly. This provides flexibility in managing deployment configurations and allows for independent versioning strategies. A typical example would be to use floating tags to represent the environments.

1. Create a folder for your application (this becomes the namespace by default)
2. Add the `CLUSTER_NAME.yaml` file with external repository configuration:

```yaml
kustomize:
  # (Required) The URL to the kustomize repository
  repository: GIT_URL
  # (Required) The path inside the repository
  path: overlays/dev
  # (Required) Use a floating tag 'dev' for the development cluster and similar for the prod
  revision: dev
```

## :material-application-array-outline: Combinational Deployment

You can combine both helm and kustomize deployments in a single file. This allows you to deploy applications that require both deployment methods.

1. Create a folder for your application, e.g. `myapp`
2. Add a `CLUSTER_NAME.yaml` file that contains both helm and kustomize configurations

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

kustomize:
  # (Required) The path to the kustomize base.
  path: kustomize
  # (Optional) Override the namespace to use for the deployment.
  namespace: override-namespace
  # (Required) Git revision
  revision: git+sha
```
