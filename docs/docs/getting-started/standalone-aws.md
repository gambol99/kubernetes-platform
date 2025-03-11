# Building Standalone Cluster in AWS

!!! note "Note"

    This documentation is a work in progress and is subject to change. Please check back regularly for updates.

This repository includes a terraform pipeline / codebase to validate locally a standalone build within AWS infrastructure. Enabling the platform team to validate any changes, add-ons, configurations and so forth before taking it to a revision.

## Prerequisites

- AWS CLI (<https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html>)
- Kubectl (<https://kubernetes.io/docs/tasks/tools/#kubectl>)
- Terraform (<https://developer.hashicorp.com/terraform/downloads>)

## Terraform

The terraform codebase can be found in the `terraform` directory. This currently uses two modules to handle the provisioning.

- [terraform-aws-eks](https://github.com/gambol99/terraform-aws-eks) - This module provisions the EKS cluster, networking, iam roles and so on.
- [terraform-kube-platform](https://github.com/gambol99/terraform-kube-platform) - This module provisions the platform components, such as ArgoCD and bootstraps the cluster with the platform.
