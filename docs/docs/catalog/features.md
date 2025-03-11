# Product Features

## Features

The following provides a collection of addons, description and the feature flag (i.e. a label within the cluster definition) to enable it.

| Chart | Namespace | Description | Feature Flag |
|-------|-----------|-------------|-------------|
| metrics-server | kube-system | Collects resource metrics from Kubelets for pod autoscaling and kubectl top | enable_metrics_server |
| volcano | volcano-system | Batch system and job scheduler for high-performance workloads | enable_volcano |
| cert-manager | cert-manager | Automatic certificate management for Kubernetes | enable_cert_manager |
| cluster-autoscaler | kube-system | Automatically adjusts the size of Kubernetes clusters | enable_cluster_autoscaler |
| external-dns | kube-system | Synchronizes exposed Services and Ingresses with DNS providers | enable_external_dns |
| external-secrets | external-secrets | Integrates external secret management systems with Kubernetes | enable_external_secrets |
| argo-cd | argocd | Declarative GitOps continuous delivery tool | enable_argocd |
| argo-events | argocd | Event-driven workflow automation framework | enable_argo_events |
| argo-rollouts | argocd-rollouts | Progressive delivery controller for Kubernetes | enable_argo_rollouts |
| argo-workflows | argo-workflows | Workflow engine for Kubernetes | enable_argo_workflows |
| ingress-nginx | ingress-nginx | Ingress controller for Kubernetes using NGINX | enable_ingress_nginx |
| keda | keda-system | Kubernetes-based Event Driven Autoscaling | enable_keda |
| kro | kro-system | Kubernetes Resource Operator for custom resources | enable_kro |
| kube-prometheus-stack | prometheus | Monitoring and alerting stack including Prometheus, Grafana, and Alertmanager | enable_kube_prometheus_stack |
| kyverno | kyverno-system | Kubernetes native policy management | enable_kyverno |
| prometheus-adapter | prometheus | Adapter to use Prometheus metrics with Kubernetes HPA | enable_prometheus_adapter |
| secrets-store-csi-driver | kube-system | Interface between Kubernetes and external secret stores | enable_secrets_store_csi_driver |
| vpa | kube-system | Vertical Pod Autoscaler for automatic CPU and memory requests | enable_vpa |
