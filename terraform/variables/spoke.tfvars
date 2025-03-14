## Path to the cluster definition
cluster_path = "../release/hub-aws/clusters/spoke.yaml"
## Override revision or branch for the platform and tenant repositories
revision_overrides = {
  platform_revision = "develop"
  tenant_revision   = "develop"
}
enable_platform = false
## Tags to apply to the EKS cluster
tags = {
  Environment = "Development"
  Product     = "EKS"
  Owner       = "Engineering"
}
# Hub Account ID is the account containing the hub
#hub_account_id = "123456789012"
vpc_cidr = "10.91.0.0/16"
