# Architectural Overview

The following provides an overviw of the components which make up the platform and the available deployment options.

## Platform Repository

Forms the baseline of all clusters, providing a tested collection of addons, policies and components, collectivity referred to as the platform, for the application teams to consume. The platform team is responsible for iterating and developing this base component, independently of the application stack; providing a resuable stack.

## Tenant Repository

The tenant repository is the consmer of a revision of the platform, and where the application developers define their applications, and additional software if required.

Which can be deployed two flavors, a central hub or a standalone instance.

## Central Hub Deployment

When using a central hub, we make use of [ArgoCD's](https://argo-cd.readthedocs.io/en/stable/) fanout pattern, where a central Kubernetes cluster running the ArgoCD stack is used to deploy to one or more clusters.
