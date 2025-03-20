## Path to the cluster definition
cluster_path = "../release/standalone-aws/clusters/dev.yaml"
## Override revision or branch for the platform and tenant repositories
revision_overrides = {
  platform_revision = "develop"
  tenant_revision   = "develop"
}

## Tags to apply to the EKS cluster
tags = {
  Environment = "Development"
  Product     = "EKS"
  Owner       = "Engineering"
}
