# ArgosCD Environment Demo

## Overview

This repository contains a demo of how to use ArgoCD to manage applications across different environments. We are assuming here we have an environment, two clusters made up of green and yellow stages, and we a self service platform that allows our development teams to deploy their applications to the clusters.

## Requirements

- Onboarding should be configuration driven.
- Teams are only exposed the minimum amount of variabes to get the applications in.
- Teams should not need the assistance of the platform team to deploy or promote their applications.
- We want to support Helm and Kustomize only for a application deployments.
- We want to support external repositories, allowing teams to take full control.
- Applications should run under difference permissions.

## Key Points

- We support two projects, `applications` and `platform`.
- The `applications` project is meant to be used by the development teams to deploy their applications.
- The `applications` project is limited by sources and resources types its permitted to deploy.
- The `platform` project is meant to be used to deploy the platform resources.
- We support deploying by either helm or kustomize (local and remote)
- The name of folder `applications/NAME` or `platform/NAME` is used to define the namespace the application will be deployed to.

## Local Development

The following instructions will help you setup a local Kubernetes cluster using kind and deploy the ArgoCD application set to it.

### Prerequisites

- kubectl (<https://kubernetes.io/docs/tasks/tools/>)
- helm (<https://helm.sh/docs/intro/install/>)
- kind (<https://kind.sigs.k8s.io/docs/user/quick-start/>)

### Steps

The following setup simulates two environments, `grn` and `yel`, using the same application set but different overlays.

### Building the Green Environment

You can build an environment, provisioning two clusters for `grn` and `yel` via

1. Run `make dev`

## Provision an Helm Application

The following steps will provision an helm application to the green environment. Note the namespace for the application is the same as the folder name.

1. Create a folder in the `mkdir applications/myapp` directory.
2. You can enable the application for the green environment by creating a `grn.yaml` file in the `applications/myapp` directory.
3. The file should like the following example:

```yaml
helm:
  chart: applications/myapp
  version: 0.1.0
  repository: https://example.com/myapp
```

4. Values for the application can be added to the `applications/myapp/values/all.yaml` file, which is used by all environments.
5. Values for the green environment only can be added to the `applications/myapp/values/grn.yaml` file, and have a higher precedence than the values in the `all.yaml` file.

### Promotion of an Helm Application

Promoting the applicaition to the next environment is as simple as duplicating the `grl.yaml` for the next environment.

```bash
cp applications/myapp/grn.yaml applications/myapp/yel.yaml
```

## Provision a Helm Application of multiple applications

It is not uncommon to have multiple helm applications that need to be deployed together, which is also supported. Lets assume you have to helm charts for `myapp` and `myapp2` that need to be deployed together with the same namespace.

1. Create a folder in the `mkdir applications/myapp` directory.
2. Create folders for each of the helm charts in the `applications/myapp` directory via `mkdir -p applications/myapp/myapp applications/myapp/myapp2`
3. Add a `grn.yaml` file to each of the helm chart folders.

In the case of the `myapp` chart the file should like the following:

```yaml
helm:
  chart: applications/myapp
  version: 0.1.0
  repository: https://example.com/myapp
```

And for the `myapp2` chart the file should like the following:

```yaml
helm:
  chart: applications/myapp2
  version: 0.1.0
  repository: https://example.com/myapp2
```

Values for boths helm charts following the same pattern as above i.e create in each of the folders `values/all.yaml` and `values/<ENVIRONMENT>.yaml`, and these will be sourced for the values.

## Provision a Kustomize Application

Provisioning a kustomize application is similar to the helm application, but the difference is the folder structure.

1. Create a folder in the `mkdir applications/myapp` directory.
2. Create the base and overlays directories in the `applications/myapp` directory via `mkdir -p applications/myapp/base applications/myapp/overlays/grn applications/myapp/overlays/yel`
3. Add a kustomization.yaml file to the `applications/myapp/overlays/grn` directory.

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
```

4. Add your kustomize resources to the `applications/myapp/base` directory.
5. Enable the kustomize application by creating a `grn.yaml` file in the `applications/myapp` directory.

```yaml
kustomize:
  revision: HEAD
```

Here you can make changes the files, and promote by updating the sha1 for a specific environment. The Application is templated out using the following

```yaml
source:
  repoURL: "{{ default .repository .kustomize.repository }}"
  targetRevision: "{{ .kustomize.revisions }}"
  path: "{{ .path.path }}/overlays/{{ .environment }}"
  kustomize: {}
```

In the above example the green environment will use the HEAD, i.e the latest revision within the base and overlays, while the yellow environment will use the git+sha1 revision; permitting you to control.

## Promotion of an Kustomize Application from existing git repository

Applications using Kustomize can also reference external git repository, with a intentional branch strategy applied.

1. Create a folder in the `mkdir applications/myapp` directory.
2. Create a `kustomize.yaml` file in the `applications/myapp` directory.

```yaml
kustomize:
  enable: true
  repository: https://github.com/gambol99/custom-kustomize.git
```

The repository revision used will be the environment name. So in the green environment the revision will be `grn` and in the yellow environment the revision will be `yel`. It is then the responsibility of the repository owner to control the floating revisions / tags on their repository.

## Restrictions on Applications

The following restrictions are applied to all applications, helm and kustomize via the [AppProject resource](./system/base/projects.yaml).

## Potential Improvements

### Remove the environment from the application sets

1. We could create a Cluster, adding the information we need as annotations on the cluster resource.

Create a secret representing the cluster.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: grn-cluster
  annotations:
    argocd.argoproj.io/cluster: grn
    environment: grn
    platform_revision: git+sha1
    platform_repository: https://github.com/gambol99/eks-services
dataString:
  name: grn
  server: https://kubernetes.default.svc
```

2. We could then update the application set to use the cluster secret.

```yaml
generators:
  - matrix:
      generators:
        - git:
            repoURL: https://github.com/gambol99/eks-services.git
            revision: HEAD
            files:
              - path: "applications/**/kustomize.yaml"
        - list:
            elements:
              - environment: grn
                repository: https://github.com/gambol99/eks-services.git
                revision: HEAD
        - cluster:
            selector:
              matchAnnotations:
                - key: environment
                  operator: Exists
```

We can then reference the cluster annotations in the application set.

```yaml
spec:
  project: applications
  source:
    repoURL: "{{ default .repository .kustomize.repository }}"
    targetRevision: "{{ default .revision (get .kustomize.revisions .platform_environment) }}"
    path: "{{ .path.path }}/overlays/{{ .platform_environment }}"
    kustomize: {}
```
