# :material-reload: Platform Setup

## :octicons-stack-24: Overview

The platform bootstrapping process follows a structured approach to set up a complete Kubernetes environment with all necessary components. This document outlines the key steps and components involved in bootstrapping the platform.

## Cluster Definition

The cluster definition contains the configuration for the platform and tenant repositories, along with metadata about the cluster. This definition drives what features are enabled and how the platform is configured.

```YAML
## The name of the tenant cluster
cluster_name: dev
## The cloud vendor to use for the tenant cluster
cloud_vendor: aws
## The environment to use for the tenant cluster
environment: development
## The repository containing the tenant configuration
tenant_repository: https://github.com/gambol99/platform-tenant.git
## The revision to use for the tenant repository
tenant_revision: HEAD
## The path inside the tenant repository to use for the tenant cluster
tenant_path: ""
## The repository containing the platform configuration
platform_repository: https://github.com/gambol99/kubernetes-platform.git
## The revision to use for the platform repository
platform_revision: HEAD
## The path inside the platform repository
platform_path: ""
## The type of cluster we are (standalone, spoke or hub)
cluster_type: standalone
## The name of the tenant
tenant: tenant_name
## We use labels to enable/disable features in the tenant cluster
labels:
  enable_cert_manager: "true"
  enable_external_dns: "false"
  enable_external_secrets: "true"
  enable_kro: "true"
  enable_kyverno: "true"
  enable_metrics_server: "true"
```

## Provisioning a Cluster

Once we have provisioned a Kubernetes cluster and installed ArgoCD, the values from this cluster definition are used to create the initial bootstrap Application. This application is fed the following

- Platform Repository and Revision: the location of the platform (i.e. this repository) and the version of the platform you want to run.
- Tenant Repository: the location of the tenant repository, which contains the cluster definitions, and tenants applications.

See the [Standalone Example Repository](https://github.com/gambol99/platform-tenant)

## Bootstrap Application

In the example terraform we extract and the required information from the cluster definition being build and use that to template the bootstrap application.

```hcl
locals {
  ## The cluster configuration
  cluster = yamldecode(file(var.cluster_path))
  ## The cluster_name of the cluster
  cluster_name = local.cluster.cluster_name
  ## The cluster type
  cluster_type = local.cluster.cluster_type
  ## The platform repository
  platform_repository = local.cluster.platform_repository
  ## The platform revision
  platform_revision = local.cluster.platform_revision
  ## The tenant repository
  tenant_repository = local.cluster.tenant_repository
}

## Provision and bootstrap the platform using an tenant repository
module "platform" {
  count = local.enable_platform ? 1 : 0
  source = "github.com/gambol99/terraform-aws-eks//modules/platform?ref=main"

  ## Name of the cluster
  cluster_name = local.cluster_name
  # The type of cluster
  cluster_type = local.cluster_type
  # Any rrepositories to be provisioned
  repositories = var.argocd_repositories
  ## The platform repository
  platform_repository = local.platform_repository
  # The location of the platform repository
  platform_revision = local.platform_revision
  # The location of the tenant repository
  tenant_repository = local.tenant_repository
  # You pretty much always want to use the HEAD
  tenant_revision = local.tenant_revision
  ## The tenant repository path
  tenant_path = local.tenant_path

  depends_on = [
    module.eks
  ]
}
```

The creates the primary Application witn the cluster, which is used to source in the Platform and the tenant repository.

```shell
$ kubectl -n argocd get applications bootstrap
bootstrap                     Synced        Healthy
```

Peeking into the Application we see

```yaml
$ kubectl -n argocd get application bootstrap -o yaml | yq .spec
destination:
  namespace: argocd
  server: https://kubernetes.default.svc
project: default
source:
  kustomize:
    patches:
      - patch: |
          - op: replace
            path: /spec/generators/0/git/repoURL
            value: https://github.com/gambol99/platform-tenant.git
          - op: replace
            path: /spec/generators/0/git/revision
            value: main
          - op: replace
            path: /spec/generators/0/git/files/0/path
            value: clusters/dev.yaml
        target:
          kind: ApplicationSet
          name: system-platform
  path: kustomize/overlays/standalone
  repoURL: https://github.com/gambol99/kubernetes-platform.git
  targetRevision: main
```

The application passes the tenany repository down into the platform as Kustomize patches, alone with the location of the cluster definition. The next important Application created off the back of this is the `system-registration` Application, which can be found [here](https://github.com/gambol99/kubernetes-platform/blob/main/apps/registration/standalone/registration.yaml).

## Cluster Registration

The cluster registration Application which is bootstrapped via the above, effectively create an application around the cluster definition, it watches for change to the file and provisions a cluster secret from the values. Hence once the cluster is provisions, all changes go via the cluster definition i.e if you want to add a feature, or change the platform revision.

```shell
$ kubectl -n argocd get applications system-registration
NAME                  SYNC STATUS   HEALTH STATUS
system-registration   Synced        Healthy
```

This used the [charts/cluster-registration](https://github.com/gambol99/kubernetes-platform/tree/main/charts/cluster-registration), creating the ArgoCD cluster secret from the values.

The bootstap also sources in the rest of the Platform application sets which are repository for providing tenant functionality as well sourcing in the platform applications themselves.
