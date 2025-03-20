## Path to the cluster definition
cluster_path           = "../release/standalone-aws/clusters/dev.yaml"
enable_nat_gateway     = false
enable_transit_gateway = true
transit_gateway_id     = "tgw-0b1b2c3d4e5cif6g7h"

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


