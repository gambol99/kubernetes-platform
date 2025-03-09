# Terraform

This folder contains the Terraform configuration for provisioning an EKS cluster and bootstrapping it with the Kubernetes platform. The code here is provided as an example implementation only, and not reflective of a production grade deployment.

The Terraform code will:

- Create a new EKS cluster in AWS
- Configure the necessary networking and IAM roles
- Bootstrap the cluster with the platform components
- Set up initial GitOps configuration

Note: This is intended as a reference implementation. For production use, you should carefully review and customize the configuration according to your requirements.

## Provision a Development Cluster

You can provision a development cluster using

```shell
terraform apply -var-file=variables/dev.tfvars
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | github.com/gambol99/terraform-aws-eks | v0.2.0 |
| <a name="module_platform"></a> [platform](#module\_platform) | github.com/gambol99/terraform-kube-platform | v0.0.2 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_path"></a> [cluster\_path](#input\_cluster\_path) | The name of the cluster | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to all resources | `map(string)` | n/a | yes |
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | Map of access entries to add to the cluster. | <pre>map(object({<br/>    ## The kubernetes groups<br/>    kubernetes_groups = optional(list(string))<br/>    ## The principal ARN<br/>    principal_arn = string<br/>    ## The policy associations<br/>    policy_associations = optional(map(object({<br/>      # The policy arn to associate<br/>      policy_arn = string<br/>      # The access scope (namespace or clsuter)<br/>      access_scope = object({<br/>        # The namespaces to apply the policy to (optional)<br/>        namespaces = optional(list(string))<br/>        # The type of access (namespace or cluster)<br/>        type = string<br/>      })<br/>    })))<br/>  }))</pre> | `{}` | no |
| <a name="input_argocd_repositories"></a> [argocd\_repositories](#input\_argocd\_repositories) | A collection of repository secrets to add to the argocd namespace | <pre>map(object({<br/>    ## The description of the repository<br/>    description = string<br/>    ## An optional password for the repository<br/>    password = optional(string, null)<br/>    ## The secret to use for the repository<br/>    secret = optional(string, null)<br/>    ## The secret manager ARN to use for the secret<br/>    secret_manager_arn = optional(string, null)<br/>    ## An optional SSH private key for the repository<br/>    ssh_private_key = optional(string, null)<br/>    ## The URL for the repository<br/>    url = string<br/>    ## An optional username for the repository<br/>    username = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | The public access to the cluster endpoint | `bool` | `true` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Enable the NAT gateway | `bool` | `true` | no |
| <a name="input_enable_platform"></a> [enable\_platform](#input\_enable\_platform) | Indicates we should install the platform | `bool` | `true` | no |
| <a name="input_hub_account_id"></a> [hub\_account\_id](#input\_hub\_account\_id) | When using a hub deployment options, this is the account where argocd is running | `string` | `null` | no |
| <a name="input_nat_gateway_mode"></a> [nat\_gateway\_mode](#input\_nat\_gateway\_mode) | The NAT gateway mode | `string` | `"single_az"` | no |
| <a name="input_private_subnet_netmask"></a> [private\_subnet\_netmask](#input\_private\_subnet\_netmask) | The netmask for the private subnets | `number` | `24` | no |
| <a name="input_public_subnet_netmask"></a> [public\_subnet\_netmask](#input\_public\_subnet\_netmask) | The netmask for the public subnets | `number` | `24` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR block for the VPC, if not using an existing VPC | `string` | `"10.90.0.0/16"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID when using an existing VPC | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_cluster_certificate_authority_data"></a> [eks\_cluster\_certificate\_authority\_data](#output\_eks\_cluster\_certificate\_authority\_data) | The certificate authority of the EKS cluster |
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | The endpoint of the EKS cluster |
| <a name="output_eks_cluster_name"></a> [eks\_cluster\_name](#output\_eks\_cluster\_name) | The name of the EKS cluster |
<!-- END_TF_DOCS -->