# Local Development

## Overview

For the purposes of local development, provisioning Kubernetes clusters in the cloud can be expensive and time consuming. And while not all the features can be fully tested locally, i.e. those relying on cloud resources, pod identity and applications (load balancers for example) and so forth, much of the development of t the platform team can be done locally on their machine.

## Provisioning a Local Cluster (Standalone)

Within the [platform repository](https://github.com/gambol99/kubernetes-platform) we have a `release` folder, which can be used to stimulate a tenant repository, keeping all the development within the same repository.

```shell
$ tree release -L2
release
├── README.md
├── hub
│   └── clusters
└── standalone
    ├── clusters
    ├── config
    └── workloads
```

## Expected Development Workflow

As a platform engineer you need to validate a new feature on a standalone deployment model.

1. Create a branch for the feature `git checkout -b feat/my-feature`
2. Update the `release/standalone/clusters/dev.yaml`, changing the branch of the tenant and platform to the `feta/my-feature` branch.
3. Commit the changes and run `make standalone`
4. The makefile will build a Kubernetes cluster in kind, using the `release/standalone` and the base tenant repository.
5. Any changes made to the branch will be reflected within the cluster, and changes are polled from the branch.
6. Once the changes have been tested, we can merge to main.

Note, if want validate changes between multiple clusters you can provision another cluster via `scripts/make-dev -c prod`.

Additional clusters can be added, simply by adding a new cluster to the `release/standalone/clusters` directory, and calling

```shell
$ scripts/make-dev.sh --cluster-name <NAME>
```

## Cleanup the Cluster

To cleanup the cluster, run `make clean`
