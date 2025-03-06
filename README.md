# EKS Platform

This repository contains a pattern for the configuration of management of a collection of Kubernetes clusters, usign ArgoCD as the deployment framework.

## Operating Model

The following depicts the operating model for the platform.

- A platform is made of up a minimum of two repositories, acting as the source of truth
  - `EKS Platform`: (this repository) provides a baseline configuration and collection of tested components.
  - `Tenant Repository`: both a consumer of this package, and the source of truth for the applications deployed to the platform.

### The Platform Team

- The platform team has ownership of the EKS Platform repository, this responsibility includes:
  - Keep the platform up to date with the latest version of the Kubernetes, and the components deployed to it.
  - Provide a tested and approved collection of components, to produce an outcome.
  - Provide a mechanism for development teams to deploy their applications to the platform.
  - Provide a security baseline for workloads running on the platform.
  - Work with the development teams to improve the platform, and the applications running on it.

## The Tenant (Development) Team

- The `Tenant Repository` is owned by the development teams, and is used to deploy their applications to the platform.
  - The consumer the platform repository as a software dependency.
  - They are responsible iterating the platform repository the revisions through the software development lifecycle i.e promoting the revisions though dev, test, and production to ensure the application stack is aligned.

## Requirements

- No centralized control plane for deployments; due to sensitivity of access, centralizing the deployments would prove problamatic for security and tenants.
- On boarding should be configuration driven, and require minimal effort from tenants.
- Teams are only exposed the minimum amount of variables to get the applications in.
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
