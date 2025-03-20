
## Provision a EKS cluster for the hub
module "eks" {
  source = "github.com/gambol99/terraform-aws-eks?ref=v0.3.3"

  access_entries                 = var.access_entries
  cluster_enabled_log_types      = null
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  cluster_name                   = local.cluster_name
  enable_nat_gateway             = var.enable_nat_gateway
  enable_transit_gateway         = var.enable_transit_gateway
  hub_account_id                 = var.hub_account_id
  hub_account_role               = "argocd-pod-identity-hub"
  nat_gateway_mode               = var.nat_gateway_mode
  private_subnet_netmask         = var.private_subnet_netmask
  public_subnet_netmask          = var.public_subnet_netmask
  tags                           = local.tags
  transit_gateway_id             = var.transit_gateway_id
  transit_gateway_routes         = var.transit_gateway_routes
  vpc_cidr                       = var.vpc_cidr
  vpc_id                         = var.vpc_id

  ## Enable the pod identity for services
  argocd = {
    enabled = local.enable_argocd_pod_identity
  }

  external_secrets = {
    enabled = var.enable_external_secrets
  }

  pod_identity = {
    crossplane = {
      description     = "Permissions for Crossplane to manage the cluster"
      name            = "crossplane-${local.cluster_name}"
      namespace       = "crossplane-system"
      service_account = "crossplane"

      managed_policy_arns = {
        AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
      }
    }
  }
}

## Provision and bootstrap the platform using an tenant repository
module "platform" {
  count  = var.enable_platform ? 1 : 0
  source = "github.com/gambol99/terraform-kube-platform?ref=v0.1.3"

  ## Name of the cluster
  cluster_name = local.cluster_name
  # The type of cluster
  cluster_type = local.cluster_type
  # Any rrepositories to be provisioned
  repositories = var.argocd_repositories
  ## Revision overrides
  revision_overrides = var.revision_overrides
  ## The platform repository
  platform_repository = local.platform_repository
  # The location of the platform repository
  platform_revision = local.platform_revision
  # The location of the tenant repository
  tenant_repository = local.tenant_repository
  # You pretty much always want to use the HEAD
  tenant_revision = local.tenant_revision
  ## The tenant repository path
  tenant_path = local.tenant_path

  depends_on = [
    module.eks
  ]
}
