# :material-application-cog: System ArgoCD Application Sets

All the application set which compose the platform can be found in

- The [apps/](https://github.com/gambol99/kubernetes-platform/tree/main/apps) directory, contains the bulk to the system and tenant appsets.
- The [kustomize/overlays/standalone](https://github.com/gambol99/kubernetes-platform/tree/main/kustomize/overlays/standalone) entrypoint.
- The [kustomize/overlays/hub](https://github.com/gambol99/kubernetes-platform/tree/main/kustomize/overlays/hub) entrypoint.

### :material-application-array-outline: Platform Application Set

The platform application sets are the entrypoint application sets for the standalone and hub cluster types. These can be found under the [kustomize/overlays](https://github.com/gambol99/kubernetes-platform/tree/main/kustomize/overlays) directory. They are solely responsible for sourcing the following application sets details below, applying kustomize patches where required.

### :material-application-array-outline: Cluster Registration Application Set

The [system-registration](https://github.com/gambol99/kubernetes-platform/tree/main/apps/registration/standalone) and the [hub version](https://github.com/gambol99/kubernetes-platform/tree/main/apps/registration/hub) are responsible for sourcing the cluster definitions from the tenant repository and producing a cluster secret, using the [charts/cluster-registration](https://github.com/gambol99/kubernetes-platform/tree/main/charts/cluster-registration) helm chart.

### :material-application-array-outline: System Helm Application Set

The [system-helm](https://github.com/gambol99/kubernetes-platform/tree/main/apps/system/system-helm.yaml) application set is responsible for installing the core platform components.

This application set merges the [addons](https://github.com/gambol99/kubernetes-platform/tree/main/addons), and then filters the applications using the labels attached within the cluster.

```yaml
generators:
  - matrix:
      generators:
        - git:
            repoURL: PLATFORM_REPO
            revision: PLATFORM_REVISION
            files:
              - path: "addons/helm/cloud/{{ .cloud_vendor }}/*.yaml"
              - path: "addons/helm/*.yaml"
          selector:
            matchExpressions:
              - key: version
                operator: Exists
              - key: repository
                operator: Exists
              - key: namespace
                operator: Exists
        - clusters:
            selector:
              matchExpressions:
                - key: environment
                  operator: Exists
                - key: "enable_{{ .feature }}"
                  operator: In
                  values: ["true"]
```

The [addons](https://github.com/gambol99/kubernetes-platform/tree/main/addons) are a collection of helm application definitions i.e

```YAML
- feature: metrics_server
  chart: metrics-server
  repository: https://kubernetes-sigs.github.io/metrics-server
  version: "3.12.2"
  namespace: kube-system

- feature: volcano
  chart: volcano
  repository: https://volcano-sh.github.io/helm-charts
  version: "1.9.0"
  namespace: volcano-system
```

Assuming the cluster selected has a label `enable_metrics_server=true` and `enable_volcano=true` in the cluster definition, the helm applications will be installed.

Currently we use the following helm values locations as the source of values to the chart.

```YAML
sources:
  - repoURL: "{{ .repository }}"
    targetRevision: "{{ .version }}"
    chart: '{{ default "" .chart }}'
    path: '{{ default "" .repository_path }}'
    helm:
      releaseName: "{{ normalize (default .feature .release_name) }}"
      ignoreMissingValueFiles: true
      valueFiles:
        - "$tenant/{{ .metadata.annotations.tenant_path }}/config/{{ .chart }}/all.yaml"
        - "$values/config/{{ .feature }}/all.yaml"

  - repoURL: "{{ .metadata.annotations.platform_repository }}"
    targetRevision: "{{ .metadata.annotations.platform_revision }}"
    ref: values

  - repoURL: "{{ .metadata.annotations.tenant_repository }}"
    targetRevision: "{{ .metadata.annotations.tenant_revision }}"
    ref: tenant
```

!!! note "Tenant Overrides"

    Note from the above configuration it is technically possible to override the values for the helm chart by adding a `all.yaml` file to the tenant repository, under a similar folder structure i.e. config/metrics-server/all.yaml.

---

#### :material-cog: Helm Values and Configuration

The configuration and helm values for the helm add-on's can be found in the [config](https://github.com/gambol99/kubernetes-platform/tree/main/config) directory. Simply create a folder named after the chart name i.e `config/metrics-server` and drop an `all.yaml` file in the folder.

By default the helm values will be sourced in the following order:

```yaml
- "$tenant/{{ .metadata.annotations.tenant_path }}/config/{{ .feature }}/{{ .metadata.labels.cloud_vendor }}.yaml"
- "$tenant/{{ .metadata.annotations.tenant_path }}/config/{{ .feature }}/all.yaml"
- "$values/config/{{ .feature }}/{{ .metadata.labels.cloud_vendor }}.yaml"
- "$values/config/{{ .feature }}/all.yaml"
```

You can find the application set [here](https://github.com/gambol99/kubernetes-platform/blob/main/apps/system/system-helm.yaml)

Another way to pass values to the Helm applications is via `parameters` i.e

```
- feature: volcano
  chart: volcano
  repository: https://volcano-sh.github.io/helm-charts
  version: "1.9.0"
  namespace: volcano-system
  parameters:
    - name: serviceAccount.annotations.test
      value: default_value

    # Reference metadata from the cluster definition
    - name: serviceAccount.annotations.test2
      value: metadata.labels.cloud_vendor
```

#### Helm Values Key Points

- The order of precedence is tenant overrides, cloud specific (i.e. `kind`, `aws`), followed by the default values in `all.yaml`.
- Next comes platform default values, again following cloud vendor, then defaults; these are located in the `config/<FEATURE>` directory.
- Tenant currently have the option to override the platform default, though we're considering dropping this feature in future releases, or at the very least making an optional in the cluster definition.

## :material-application-array-outline: System Kustomize Application Set

The [system-kustomize](https://github.com/gambol99/kubernetes-platform/blob/main/apps/system/system-kustomize.yaml) is responsible for provisioning any kustomize related functionality from the system. The application set use's a [git generator](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Git/) to source all the `kustomize.yml` from the [addons/kustomize](https://github.com/gambol99/kubernetes-platform/tree/main/addons/kustomize) directory.

Kustomize applications are defined in a similar manner to helm applications, with the following fields:

```YAML
---
kustomize:
  ## Human friendly description
  description: ""
  ## The feature flag used to enable the feature
  feature: <FEATURE>
  ## The path to the kustomize overlay
  path: base
  ## Optional patches to apply to the kustomize overlay
  patches:
    - target:
        kind: <KIND>
        name: <NAME>
      path: <PATH>
      key: <KEY>
      default: <DEFAULT>

## The namespace options
namespace:
  ## The name of the namespace to deploy the application
  name: kube-system

## Synchronization options
sync:
  ## How to order the deployment of the resources
  phase: primary
```

Note, kustomize application support the use of patching, but taking fields from the cluster definitions labels and annotations, and using then as values in the patches.

```yaml
## Optional patches to apply to the kustomize overlay
patches:
  - target:
      kind: Namespace
      name: test
    path: /metadata/annotations/environment
    key: metadata.annotations.environment
    default: unknown
```

In the above example, the `metadata.annotations.environment` value from the cluster definition will be used as the value for the patch.

### External Kustomize Repository

System applications using Kustomize also support the option to source in an external repository. This can be used by definiting the following

```yaml
kustomize:
  ## The feature used to toggle the addon
  feature: kyverno
  ## The path inside the repositor
  path: kustomize
  ## External repository, else by default we use the platform repository and revision
  repository: https://github.com/gambol99/exteranl-repository.git
  ## The revision for the above repository
  revision: HEAD
```
