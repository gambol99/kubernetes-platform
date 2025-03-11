# Standalone Deployment

!!! note "Note"

    This documentation is a work in progress and is subject to change. Please check back regularly for updates.

The following tries to depict a typical standalone deployment. You can find the example code base for this walk-through at [https://github.com/gambol99/platform-tenant](https://github.com/gambol99/platform-tenant)

## :octicons-cross-reference-24: Example Scenerio

Using the following scenario, we have

| Feature | Description |
|---------|-------------|
| Multiple Environments | Two Kubernetes clusters (`dev` and `prod`) representing different environments in the application life cycle |
| Independent Platform Upgrades | Each cluster runs its own version of the platform, allowing independent platform upgrades and testing |
| GitOps Workflows | Application teams can deploy and manage their applications using GitOps workflows |
| Controlled Promotion | Changes to both platform and applications can be promoted between environments in a controlled manner |
| Version Tracking | Platform versions are defined in code, enabling clear tracking of what's running where |
| Team Autonomy | Application teams have autonomy to deploy, test, and promote |

## :octicons-cpu-24: Required Binaries

- Kind (<https://kind.sigs.k8s.io/docs/user/quick-start/#installation>)
- kubectl (<https://kubernetes.io/docs/tasks/tools/#kubectl>)
- Terraform (<https://developer.hashicorp.com/terraform/downloads>)

## :octicons-project-roadmap-24: Setup the Environments

We need to provision a repository to house the tenant application stack, we can use the template [EKS Tenant](https://github.com/gambol99/eks-tenant). Clone repository via

```shell
gh repo clone gambol99/provision-tenant
```

The folder structure of a tenant repository is as follows.

- **clusters** - contains the cluster definitions for both development and production clusters.
- **workloads** - contains the ArgoCD application definitions for the tenant applications.
- **workloads/applications** - contains the application definitions for standard applications, which run under the tenant project.
- **workloads/platform** - contains the application definitions for system applications, which run under a higher privilege.
- **terraform** - contains the Terraform code to provision the tenant cluster/s.
- **terraform/variables** - contains the Terraform variables for the tenant cluster/s.

## Cluster Definitions

A typical [cluster definition](https://github.com/gambol99/platform-tenant/blob/main/clusters/dev.yaml) is as follows

```yaml
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

Noteworthy section are the `labels`. Label are used by the platform to control whether a piece of [functionality is installed](https://github.com/gambol99/kubernetes-platform/blob/main/apps/system/system-helm.yaml#L60-L67) via the platform.

The following depicts a typical setup using the standalone deployment option. We have an application stacks and te

Under this arrangement

- ArgoCD is installed on the cluster itself, with all deployments installing on the same cluster.
- The tenany repository points at the version of the platform, and contains the applications stack.

| Feature | Description |
|---------|-------------|
| Multiple Environments | Two Kubernetes clusters (`dev` and `prod`) representing different environments in the application life cycle |
| Independent Platform Upgrades | Each cluster runs its own version of the platform, allowing independent platform upgrades and testing |
| GitOps Workflows | Application teams can deploy and manage their applications using GitOps workflows |
| Controlled Promotion | Changes to both platform and applications can be promoted between environments in a controlled manner |
| Version Tracking | Platform versions are defined in code, enabling clear tracking of what's running where |
| Team Autonomy | Application teams have autonomy to deploy, test, and promote |
