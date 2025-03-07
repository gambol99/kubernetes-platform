# Architectural Overview

The following provides an overview of the components which make up the platform and the available deployment options.

![Image title](images/image.png){ align=left }
hello

## Platform Repository

Forms the baseline of all clusters, providing a tested collection of add-ons, policies and components, collectivity referred to as the platform, for the application teams to consume. The platform team is responsible for iterating and developing this base component, independently of the application stack; providing a reusable stack.

## Tenant Repository

The tenant repository is the consumer of a revision of the platform, and where the application developers define their applications, and additional software if required.

Which can be deployed two flavors, a central hub or a standalone instance.

## Central Hub Deployment

When using a central hub, we make use of [ArgoCD's](https://argo-cd.readthedocs.io/en/stable/) fan-out pattern, where a central Kubernetes cluster running the ArgoCD stack is used to deploy to one or more clusters.
