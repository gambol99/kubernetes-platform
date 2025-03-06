# Tenant Namespace

## Overview

When deploying applications in either `workloads/applications/` or `workloads/system/`, any new namespace that gets created will automatically receive a default bundle of Kubernetes resources. This standardizes namespace configuration and security across the platform.

## Default Resources

The following resources are automatically provisioned in each new namespace:

### Network Policies

- Default deny-all policy with explicit allow rules for required communication
- Policies to allow monitoring and logging components to scrape metrics
- Inter-namespace communication rules based on platform standards

### RBAC Resources

- Default Role and RoleBinding for namespace access
- Service account configurations
- Resource quotas and limits

### Ingress Rules

- Base ingress configurations and routing rules
- TLS certificate management settings
- Load balancer annotations and configurations

This automated namespace provisioning ensures:

- Consistent security controls across all namespaces
- Standardized access patterns and permissions
- Proper network isolation and communication paths
- Uniform ingress and routing configurations

Teams can extend these base configurations through their application deployments while maintaining platform security standards.

You can find the default manifests [here](https://github.com/gambol99/kubernetes-platform/tree/main/apps/tenant/namespace)
