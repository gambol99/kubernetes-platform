# :material-developer-board: Hub & Spoke

## :octicons-grabber-24: Overview

When developing features that involve hub and spoke cluster configurations, you'll need at least two Kubernetes clusters:

1. A hub cluster that serves as the central management plane
2. One or more spoke clusters that are managed by the hub

This setup allows you to test:

- Cross-cluster communication and management
- Application deployment across clusters
- Policy enforcement and governance
- Multi-cluster observability
- Resource federation and sharing

## Architecture

In the Hub-Spoke model, a centralized hub cluster is designated to host the Argo CD instance. This hub cluster serves as the control center and is responsible for managing resources across multiple spoke clusters. The spoke clusters, which could be numerous (e.g., 5 or 10), rely on the hub cluster for coordination and deployment. The Argo CD instance in the hub cluster is configured to oversee and make changes to the other clusters, offering a centralized and streamlined approach to cluster management.

<figure markdown="span">
  ![Image title](/assets/images/argocd-hub-and-spoke.png){ align=center }
</figure>

## :octicons-tools-16: Prerequisites

The following tools need to be installed on your local machine:

| Tool      | Description                                     | Installation Link                                                    |
| --------- | ----------------------------------------------- | -------------------------------------------------------------------- |
| kubectl   | The Kubernetes command-line tool                | [Install Guide](https://kubernetes.io/docs/tasks/tools/#kubectl)     |
| helm      | The package manager for Kubernetes              | [Install Guide](https://helm.sh/docs/intro/install/)                 |
| terraform | Infrastructure as Code tool for cloud resources | [Install Guide](https://developer.hashicorp.com/terraform/downloads) |

## :octicons-project-roadmap-24: Setup the Environments

The `release` folder is used to mimic a tenant repository locally. Under `release/hub-aws` you will find the necessary files required to manage, test and develop with the hub and spoke setup.

```shell
$ tree release/hub-aws/ -L 1
release/hub-aws/
├── clusters
├── config
└── workloads
```

1. We have two cluster definitions [hub.yaml](https://github.com/gambol99/kubernetes-platform/blob/main/release/hub-aws/clusters/hub.yaml) and [spoke.yaml](https://github.com/gambol99/kubernetes-platform/blob/main/release/hub-aws/clusters/spoke.yaml)
2. Note, similar to local development with [local](https://gambol99.github.io/kubernetes-platform/development/local/) and the [standalone](https://gambol99.github.io/kubernetes-platform/development/standalone/) development, the revision found in the cluster definitions are overridden, allowing you to use your current branch to validate changes.

### :octicons-rocket-24: Provision the Hub cluster

1. Take a look at the terraform code in the `terraform` directory, and update any `terraform/variables/hub.tfvars` you feel need changing.
2. Run the Makefile `make hub-aws`; this will run `terraform init`, `terraform workspace select hub` and provision the cluster.
3. Once the Hub has been provision `aws eks update-kubeconfig --name hub` and verify everything is working, we should see a collection of applications similar to below

!!! note "Note"

    You can view what the Makefile target is doing by opening the `terraform/Makefile`

```shell
kubectl -n argocd get applications
$ k -n argocd get applications
NAME                                 SYNC STATUS   HEALTH STATUS
bootstrap                            Synced        Healthy
platform                             Synced        Healthy
system-argocd-hub                    Synced        Healthy
system-aws-ack-iam-spoke             Unknown       Unknown
system-cert-manager-spoke            Unknown       Unknown
system-external-secrets-hub          Synced        Healthy
system-external-secrets-spoke        Unknown       Unknown
system-kro-spoke                     Unknown       Unknown
system-kust-cert-manager-spoke       Unknown       Unknown
system-kust-external-secrets-hub     Synced        Healthy
system-kust-external-secrets-spoke   Unknown       Unknown
system-kust-karpenter-hub            Synced        Healthy
system-kust-karpenter-spoke          Unknown       Unknown
system-kust-kyverno-hub              OutOfSync     Healthy
system-kust-kyverno-spoke            Unknown       Unknown
system-kust-priority-hub             Synced        Healthy
system-kust-priority-spoke           Unknown       Unknown
system-kyverno-hub                   Synced        Healthy
system-kyverno-spoke                 Unknown       Unknown
system-registration-hub              Synced        Healthy
system-registration-spoke            Synced        Healthy
```

The `Unknown` is expected, as the cluster is enabled in the cluster definition, but no server endpoint or authentication has been supplied to ArgoCD yet.

### :octicons-rocket-24: Provision the Spoke

With the Hub cluster provisioned we can now move forward and provision our first spoke cluster (we can consider this one dev).

1. Update any required changes (VPC cidr etc) in the `terraform/variables/spoke.tfvars`.
2. Run the Makefile target `make spoke-aws`; against this will initialized the terraform, select a workspace `spoke` and run terraform apply.
3. We should have an empty EKS cluster now for the spoke.

Now we have to configure the authentication from the Hub to the Spoke.

## Cluster Authentication

Authentication between the Hub ArgoCD and the spoke cluster is performed using pod identity. Each spoke has cross account role provisioned when the `var.hub_account_id` is defined. A trust policy is created allowing Hub account to assume this role, and via access entities this role is assumed to cluster administrator.

Note, the is nothing to stop you using another method, ArgoCD supports the following [https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#clusters](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#clusters) mode. You can use the `cluster_authentication.config` in the cluster definition and fill in any of the above methods of authentication.

Below is the cross account role.

```hcl
## Create IAM Role for ArgoCD cross-account access
resource "aws_iam_role" "argocd_cross_account_role" {
  count = local.enable_cross_account_role ? 1 : 0

  name = "${var.cluster_name}-argocd-cross-account"
  tags = local.tags

  # Trust policy that allows the ArgoCD account to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCrossAccountAssumeRole"
        Effect = "Allow",
        Principal = {
          AWS = format("arn:aws:iam::%s:root", var.hub_account_id)
        },
        Action    = "sts:AssumeRole",
        Condition = {}
      }
    ]
  })
}

```

!!! note "Note"

    You could bypass the updating of the cluster configuration by simply added an known endpoint i.e create route53 domain and use the EKS endpoint as a CNAME

On the Hub cluster [pod identity](https://github.com/gambol99/terraform-aws-eks/blob/main/pod_identity.tf#L1-L29) allows the ArgoCD service account to assume the roles in the spoke accounts. The only manually change currently is adding in the Kubernetes endpoints URL post the creation.

1. Once a spoke have been provisioned, you will have the Kubernetes endpoints URL in the terraform outputs or AWS Console.
2. We need to update the cluster definition in the spoke to include this information i.e. below

```yaml
## The authentication details for the cluster
cluster_authentication:
  ## The server to use for the cluster
  server: UPDATE_THE_EKS_ENDPOINT
  ## The configuration to assume the role using the cross account role
  config:
    awsAuthConfig:
      clusterName: spoke
      roleARN: arn:aws:iam::UPDATE_SPOKE_ACCOUNT_ID:role/spoke-argocd-cross-account
    tlsClientConfig:
      insecure: true
```

ArgoCD in the hub should now have everything it needs to communicate with spoke.

1. Go back to the Hub cluster and run `kubectl -n argocd get applications` you should see the spoke applications now.

```shell
$ kubectl -n argocd get applications
NAME                                 SYNC STATUS   HEALTH STATUS
bootstrap                            Synced        Healthy
platform                             Synced        Healthy
system-argocd-hub                    Synced        Healthy
system-aws-ack-iam-spoke             Synced        Healthy
system-cert-manager-spoke            Synced        Healthy
system-external-secrets-hub          Synced        Healthy
system-external-secrets-spoke        Synced        Healthy
system-kro-spoke                     Synced        Healthy
system-kust-cert-manager-spoke       Synced        Healthy
system-kust-external-secrets-hub     Synced        Healthy
system-kust-external-secrets-spoke   Synced        Healthy
system-kust-karpenter-hub            Synced        Healthy
system-kust-karpenter-spoke          Synced        Healthy
system-kust-kyverno-hub              OutOfSync     Healthy
system-kust-kyverno-spoke            Synced        Healthy
system-kust-priority-hub             Synced        Healthy
system-kust-priority-spoke           Synced        Healthy
system-kyverno-hub                   Synced        Healthy
system-kyverno-spoke                 Synced        Healthy
system-registration-hub              Synced        Healthy
system-registration-spoke            Synced        Healthy
```

To start deploying applications to the spoke cluster, you can use the `workloads` directory in the `release/hub-aws` directory. View the [workloads](/platform/tenant/applications/) documentation for more information.
