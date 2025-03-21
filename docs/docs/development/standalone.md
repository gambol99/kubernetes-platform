# Provision a Standalone Cluster

## :octicons-stack-24: Overview

The following walks through the steps required to provision a standalone cluster/s within AWS. Here we will be using the internal terraform code found in `terraform` directory to provision the infrastructure.

## :octicons-beaker-24: Validating Change

**Requirement**: As a platform engineer, you need to provision a development cluster in AWS to validate and test platform changes before merging to the release branch, and potentially incorporated with a release. This involves:

- Creating a feature branch for development
- Provisioning a standalone AWS cluster for testing
- Validating the changes in an isolated environment  
- Submitting pull requests once testing is complete

## :octicons-rocket-24: Provision the cluster

We can use the `terraform` code to provision a EKS cluster for us, and onboard the platform.

1. Create a branch to commit your changes i.e `git checkout -b feat/my_change`.
2. Open the `terraform/variables/dev.tfvars`, this can be used to provision a cluster from or copied as a template.
3. Provision a cluster using terraform; note if you are reusing the `dev.tfvars` you can simply run `make standalone-aws`.
    1. If using another `variables` file, you must run terraform manually via `terraform apply -var-file=variables/FILE.tfvars`
4. Similar to the local development proccess using kind the branch the cluster is provisioned with is overrided, and uses the current branch, as oppposed one defined within the cluster definition.
5. At the point we should have a EKS cluster, which we can access using `kubectl`.

```shell
$ aws eks update-kubeconfig --name dev
Updated context arn:aws:eks:eu-west-2:xxx:cluster/dev in /Users/jest/.kube/config
```

## :octicons-beaker-24: Validate the Cluster

1. Check the applications have been provisioned correctly via `kubectl -n argocd get applications`

## :octicons-verified-24: Applying Changes

From here on in, any changes to the branch will automatically be replicated as the source of truth to the cluster, we can validate the changes are working and once happy, raise the pull request.
