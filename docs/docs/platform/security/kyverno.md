# Kyverno Policies

## Overview

Kyverno is a policy engine designed for Kubernetes that validates, mutates, and generates configurations using policies as Kubernetes resources. It provides key features like:

- Policy validation and enforcement
- Resource mutation and generation 
- Image verification and security controls
- Audit logging and reporting
- Admission control webhooks

The following policies are shipped by default in this platform to enforce security best practices, resource management, and operational standards.

For detailed information about Kyverno's capabilities, refer to the [official documentation](https://kyverno.io/docs/) or [policy library](https://kyverno.io/policies/).

---
## :material-shield-lock: Rule: deny-empty-ingress-host

**Category:** Best Practices | **Severity:** medium | **Scope:** Cluster-wide

An ingress resource needs to define an actual host name in order to be valid. This policy ensures that there is a hostname for each rule defined.

**Rules**

- **disallow-empty-ingress-host** (Validation)

---

## :material-shield-lock: Rule: require-labels

**Category:** Best Practices | **Severity:** medium | **Scope:** Cluster-wide

Define and use labels that identify semantic attributes of your application or Deployment. A common set of labels allows tools to work collaboratively, describing objects in a common manner that all tools can understand. The recommended labels describe applications in a way that can be queried. This policy validates that the labels `app.kubernetes.io/name`, `app.kubernetes.io/version`, and `app.kubernetes.io/part-of` are specified with some value.

**Rules**

- **check-for-labels** (Validation)

- **check-deployment-template-labels** (Validation)

---

## :material-shield-lock: Rule: deny-no-limits

**Category:** Best Practices, EKS Best Practices | **Severity:** medium | **Scope:** Cluster-wide

As application workloads share cluster resources, it is important to limit resources requested and consumed by each Pod. It is recommended to require resource requests and limits per Pod, especially for memory and CPU. If a Namespace level request or limit is specified, defaults will automatically be applied to each Pod based on the LimitRange configuration. This policy validates that all containers have something specified for memory and CPU requests and memory limits.

**Rules**

- **validate-resources** (Validation)

---

## :material-shield-lock: Rule: deny-external-secrets

**Category:** Security | **Severity:** medium | **Scope:** Cluster-wide

When provisioning ExternalSecrete, the key must be prefixed with the namespace name to ensure proper isolation and prevent unauthorized access.

**Rules**

- **namespace-prefix** (Validation)
  - Applies to: ExternalSecret

---

## :material-shield-lock: Rule: deny-nodeport-service

**Category:** Best Practices | **Severity:** medium | **Scope:** Cluster-wide

A Kubernetes Service of type NodePort uses a host port to receive traffic from any source. A NetworkPolicy cannot be used to control traffic to host ports. Although NodePort Services can be useful, their use must be limited to Services with additional upstream security checks. This policy validates that any new Services do not use the `NodePort` type.

**Rules**

- **validate-nodeport** (Validation)

---

## :material-shield-lock: Rule: deny-default-namespace

**Category:** Multi-Tenancy | **Severity:** medium | **Scope:** Cluster-wide

Kubernetes Namespaces are an optional feature that provide a way to segment and isolate cluster resources across multiple applications and users. As a best practice, workloads should be isolated with Namespaces. Namespaces should be required and the default (empty) Namespace should not be used. This policy validates that Pods specify a Namespace name other than `default`. Rule auto-generation is disabled here due to Pod controllers need to specify the `namespace` field under the top-level `metadata` object and not at the Pod template level.

**Rules**

- **validate-namespace** (Validation)

- **validate-podcontroller-namespace** (Validation)

---

## :material-shield-lock: Rule: deny-latest-image

**Category:** Best Practices | **Severity:** medium | **Scope:** Cluster-wide

The ':latest' tag is mutable and can lead to unexpected errors if the image changes. A best practice is to use an immutable tag that maps to a specific version of an application Pod. This policy validates that the image specifies a tag and that it is not called `latest`.

**Rules**

- **require-image-tag** (Validation)

- **validate-image-tag** (Validation)

---

## :material-shield-lock: Rule: deny-no-pod-probes

**Category:** Best Practices, EKS Best Practices | **Severity:** medium | **Scope:** Cluster-wide

Liveness and readiness probes need to be configured to correctly manage a Pod's lifecycle during deployments, restarts, and upgrades. For each Pod, a periodic `livenessProbe` is performed by the kubelet to determine if the Pod's containers are running or need to be restarted. A `readinessProbe` is used by Services and Deployments to determine if the Pod is ready to receive network traffic. This policy validates that all containers have one of livenessProbe, readinessProbe, or startupProbe defined.

**Rules**

- **deny-no-pod-probes** (Validation)

---

## :material-shield-lock: Rule: deny-cap-net-raw

**Category:** Best Practices | **Severity:** medium | **Scope:** Cluster-wide

Capabilities permit privileged actions without giving full root access. The CAP_NET_RAW capability, enabled by default, allows processes in a container to forge packets and bind to any interface potentially leading to MitM attacks. This policy ensures that all containers explicitly drop the CAP_NET_RAW ability. Note that this policy also illustrates how to cover drop entries in any case although this may not strictly conform to the Pod Security Standards.

**Rules**

- **require-drop-cap-net-raw** (Validation)

---

**Total Policies: 9**
