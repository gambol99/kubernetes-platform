# Remote Development

## Overview

While iterating using Kind can cover a large portion of the development cycle, there are certain aspects that need to be tested in a live cluster environment. These include:

- Pod identity and IAM role integration
- Cloud provider-specific add-ons and services
- Load balancer and ingress controller behavior
- Storage class and volume provisioning
- Auto-scaling and cluster autoscaler functionality
- Cloud-specific networking features
- Service mesh integrations
- Monitoring and logging infrastructure

For these scenarios, it's recommended to:

1. Use a dedicated development/test cluster in your cloud provider
2. Keep the cluster isolated from production workloads
3. Enable necessary cloud provider features and add-ons
4. Configure appropriate IAM roles and permissions
5. Test with realistic workload patterns
6. Monitor costs and clean up test resources

This allows you to validate platform changes in an environment that closely matches production, while maintaining a safe space for experimentation.
