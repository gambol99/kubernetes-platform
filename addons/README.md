# Deployment Formats

The following describes the different formats that can be used to deploy the platform.

## Helm

You can deploy using a helm chart, by adding a helm.yaml.

1. Create a folder (by default this becomes the namespace)
2. Add a helm.yaml file

```yaml
helm:
  # (Required) A feature flag to enable/disable the deployment. The cluster
  # labels are using to determine if the cluster should have the application
  # deployed to it.
  feature: enable_application
  ## (Optional) The chart to use for the deployment.
  chart: ./charts/platform
  ## (Optional) The path inside a repository to the chart to use for the deployment.
  path: ./charts/platform
  ## (Required) The release name to use for the deployment.
  release_name: platform
  ## (Required) The version of the chart to use for the deployment.
  version: 0.1.0
  ## (Optional) An override for the namespace to use for the deployment.
  namespace: override-namespace

## Sync Options
sync:
  # (Optional) The phase to use for the deployment, used to determine the order of the deployment.
  phase: primary|secondary
  # (Optional) The duration to use for the deployment.
  duration: 30s
  # (Optional) The max duration to use for the deployment.
  max_duration: 5m
```

In order to use values, you need to create a values.yaml file.

1. For the values, create a folder called `values` inside the folder you created in step 1.
2. Add a `all.yaml` file to the values folder, which will be used to deploy the application.

## Helm with Multiple Charts

Similar to the helm deployment, create a folder for your deployments. Taking the example of two charts, frontend and backend, you would create a folder called `frontend` and `backend`.

1. Create a folder called for the application, e.g. `myapp`
2. Create two folders inside the `myapp` folder, `frontend` and `backend`
3. Add a `helm.yaml` file to the `frontend` folder.
4. You can same format as above for the `helm.yaml` file.
5. Add a `values` folder to the `frontend` folder, and add a `all.yaml` file to the values folder.
6. Add a `values` folder to the `backend` folder, and add a `all.yaml` file to the values folder.

## Kustomize

You can deploy using kustomize, by adding a kustomize.yaml.

1. Create a folder (by default this becomes the namespace)
2. Add a kustomize.yaml file

```yaml
kustomize:
  # (Required) The feature flag to enable/disable the deployment.
  feature: enable_application
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
