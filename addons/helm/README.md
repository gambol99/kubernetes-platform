# Helm Addons

This directory contains the helm charts for the open source and cloud specific addons.

## Helm Entry Format

The helm entry format is as follows:

```yaml
- feature: enable_argo_workflows
  chart: argo-workflows
  repository: https://argoproj.github.io/argo-helm
  version: "0.45.8"
  namespace: argocd
```

The following fields are supported:

- `feature`: The feature is a label which must be defined on the cluster definition for the feature to be enabled.
- `chart`: Optional chart name to use for the release (assuming the repository is a helm repository).
- `repository`: The repository is the location of a helm repository to install the chart from.
- `path`: Optional path inside the repository to install the chart from (assuming the repository is a git repository).
- `version`: The version of the chart to install or the git reference to use (e.g. `main`, `HEAD`, `v0.1.0`).
- `namespace`: The namespace to install the chart into.

All the fields are optional except for `path` and `chart`, as they are dependent on if the repository is a helm repository or a git repository.
