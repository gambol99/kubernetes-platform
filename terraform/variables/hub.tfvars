## Path to the cluster definition
cluster_path = "../clusters/hub/hub.yaml"
## The SSO identity role
sso_role_name = "AWSReservedSSO_Administrator_fbb916977087a86f"
## Tags to apply to the EKS cluster
tags = {
  Environment = "Production"
  Product     = "EKS"
  Owner       = "Engineering"
}
