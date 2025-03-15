# Network Security

## Introduction to Cilium

Cilium is an open-source software for providing and transparently securing network connectivity and load balancing between application workloads such as application containers or processes.

It leverages eBPF (extended Berkeley Packet Filter) technology to provide high-performance networking, security, and observability.

## Feature Set

- **Network Security**: Provides fine-grained security policies for network communication between workloads.
- **Load Balancing**: Offers efficient load balancing for both east-west and north-south traffic.
- **Network Visibility**: Delivers deep visibility into network traffic and application behavior.
- **Transparent Encryption**: Ensures data-in-transit encryption without requiring changes to applications.
- **Identity-Aware Security**: Uses identity-based security policies rather than relying on IP addresses.
- **Integration with Kubernetes**: Seamlessly integrates with Kubernetes for network policy enforcement and service discovery.

## mTLS Implementation in Cilium

Cilium implements mutual TLS (mTLS) to provide end-to-end encryption and authentication between workloads. mTLS ensures that both the client and server authenticate each other, providing a higher level of security compared to traditional TLS.

### How mTLS Works in Cilium

1. **Certificate Management**: Cilium uses certificates to authenticate workloads. These certificates are typically managed by a certificate authority (CA) and distributed to workloads.
2. **Policy Enforcement**: Cilium's network policies can specify that mTLS must be used for communication between certain workloads. This ensures that only authenticated and authorized workloads can communicate.
3. **Encryption**: All data transmitted between workloads is encrypted using mTLS, ensuring data confidentiality and integrity.
4. **Integration with eBPF**: Cilium leverages eBPF to efficiently enforce mTLS policies and handle encryption/decryption operations at the kernel level, providing high performance and low latency.
5. **Traffic Filtering**: By intercepting TLS traffic, Cilium can apply fine-grained security policies to filter traffic based on various criteria such as identity, service, and more. When using SPIRE, Cilium can leverage the SPIFFE IDs provided by SPIRE to enforce identity-based policies.

By using mTLS, Cilium provides a robust security mechanism that protects against various network threats, including man-in-the-middle attacks and unauthorized access.
