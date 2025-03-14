# Kustomize Addons  

This directory contains the kustomize manifests for the open source and cloud specific addons.

## Kustomize Entry Format

The kustomize entry format is as follows:

```yaml
kustomize:
  ## The flag to toggle the feature
  feature: kyverno
  ## The path inside the repository 
  path: kustomize
  ## The location of an external kustomize repository (optional)
  repository = URL
  ## The revision of the external repository (optional)
  revision: BRANCH|TAG
  ## Apply a patch
  patches:
    - target:
        kind: ClusterPolicy
        name: deny-default-namespaces
      patch:
        - op: add
          path: /spec/background
          key: metadata.annotations.platform_revision
          default: "false"

namespace:
  ## Name of the namespace to deploy the application
  name: kyverno-system
  ## Name of the SKU to deploy the application
  sku: small

## Synchronization options
sync:
  ## We want to deploy kyverno after the platform
  phase: secondary
```

Under the `kustomize` entry, the following fields are supported:

- `feature`: The feature is a label which must be defined on the cluster definition for the feature to be enabled.
- `path`: The path to the kustomize manifest to apply.
- `patches`: A list of patches to apply to the kustomize manifest (Optional).

## Kustomize Patches

The patches are applied to the kustomize manifest using the [kustomize patch](https://kubectl.docs.kubernetes.io/references/kustomize/patches/) command.

The following fields are supported:

- `target`: The target is the resource to apply the patch to.
- `patch`: The patch is the patch to apply to the resource.

The target is used to identify the resource to apply the patch to. The following fields are supported:

- `kind`: The kind of the resource to apply the patch to.
- `name`: The name of the resource to apply the patch to.

The `patches` is a list of operations to apply to the resource. The following operations are supported:

- `op`: Is the operation to apply to the resource i.e. `add`, `replace`.
- `path`: The path to the field to apply the operation to.
- `key`: The key can lookup a value from the cluster definition and apply it to the field i.e. `metadata.annotations.platform_revision`.
- `default`: The default value to apply to the field if the key is not found or empty in the cluster definition.

## Kustomize Synchronization

The synchronization entry is used to configure the synchronization options for ArgoCD. The following fields are supported:

- `phase`: The phase to deploy the application to.  
- `max_duration`: The maximum duration to wait for the application to synchronize.
