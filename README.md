# EKS Platform

This repository contains a pattern for the configuration of management of a collection of Kubernetes clusters, usign ArgoCD as the deployment framework.

## Why This Pattern?

Managing multiple Kubernetes clusters across different environments presents challenges in consistency, scalability, and automation. This solution provides:

- Standardized provisioning – Automate cluster creation with Infrastructure as Code (IaC).
- GitOps-based management – Declarative, version-controlled deployments using ArgoCD.
- Flexible architectures – Support for both distributed and hub-and-spoke models.
- Secure multi-cluster operations – Enforce policies, RBAC, and secrets management at scale.
- Tenants Applications - Provides tenants consumers an easy way to onboard their workloads.

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

### The Tenant (Development) Team

- The `Tenant Repository` is owned by the development teams, and is used to deploy their applications to the platform.
  - The consumer the platform repository as a software dependency.
  - They are responsible iterating the platform repository the revisions through the software development lifecycle i.e promoting the revisions though dev, test, and production to ensure the application stack is aligned.

## Platform Tenets

Too often, platforms are designed from a purely technical standpoint, packed with cutting-edge tools and complex abstractions—yet they fail to deliver a great developer experience. They become rigid, overwhelming, and unintuitive, forcing teams to navigate layers of complexity just to deploy and operate their workloads.

This is where strong platform tenets come in.

- Treat the platform as a product, not just infrastructure—it should have clear users, a roadmap, and continuous improvements.
- Focus on developer experience make workflows intuitive and efficient.
- Provide self-service capabilities for developers to deploy and manage workloads independently.
- Ensure guardrails, not gates—provide secure defaults but allow flexibility when needed.
- Optimize for usability and maintainability, not just technical capability.
- Reduce cognitive load by abstracting unnecessary infrastructure details.
- Follow opinionated defaults but allow extensibility for advanced use cases.

## Deployment Options

Currently the platform is supported in two flavors

- Central Hub: here we are using the fanout pattern of ArgoCD to act as a central control plane across multiple clusters.
- Standalone: under the this model a cluster is bootstrapped with ArgoCD, and the platform and tenant repositories manage the cluster underneath.

## Getting Started
