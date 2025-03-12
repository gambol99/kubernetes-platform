
## Provision a EKS cluster for the hub
module "eks" {
  source = "github.com/gambol99/terraform-aws-eks?ref=v0.2.3"

  access_entries                 = var.access_entries
  cluster_enabled_log_types      = null
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  cluster_name                   = local.cluster_name
  enable_argocd_pod_identity     = (local.cluster_type == "hub" ? true : false)
  enable_nat_gateway             = var.enable_nat_gateway
  hub_account_id                 = var.hub_account_id
  nat_gateway_mode               = var.nat_gateway_mode
  private_subnet_netmask         = var.private_subnet_netmask
  public_subnet_netmask          = var.public_subnet_netmask
  tags                           = local.tags
  vpc_cidr                       = var.vpc_cidr
  vpc_id                         = var.vpc_id
}

## Provision and bootstrap the platform using an tenant repository
module "platform" {
  count  = var.enable_platform ? 1 : 0
  source = "github.com/gambol99/terraform-kube-platform?ref=v0.1.2"

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
