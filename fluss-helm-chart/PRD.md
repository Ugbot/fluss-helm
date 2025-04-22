# FLUSS Helm Chart - Product Requirements Document (PRD)

## 1. Introduction

This document outlines the requirements for a Helm chart to deploy and manage the FLUSS streaming layer on Kubernetes. FLUSS provides scalable and fault-tolerant stream storage and processing capabilities, building upon Apache Flink.

## 2. Goals

*   Provide a simple, standardized way to deploy FLUSS on Kubernetes.
*   Allow flexible configuration of FLUSS components (Coordinator, Tablet Servers).
*   Support optional deployment of dependencies like ZooKeeper, Flink, and MinIO.
*   Enable persistence options for critical state.
*   Facilitate easy upgrades and rollbacks.
*   Adhere to Helm best practices.

## 3. Non-Goals

*   Deploying FLUSS on platforms other than Kubernetes.
*   Managing the underlying Kubernetes cluster infrastructure.
*   Providing deep operational monitoring beyond basic readiness/liveness probes (though integration points should be considered).

## 4. User Stories

*   As a Platform Engineer, I want to deploy a complete FLUSS cluster with default settings using a single Helm command.
*   As a Developer, I want to configure resource limits (CPU, memory) for FLUSS components.
*   As an Operator, I want to enable persistence using MinIO deployed via the chart.
*   As an Operator, I want to connect FLUSS to an existing external ZooKeeper cluster.
*   As a Developer, I want to deploy an integrated Flink cluster alongside FLUSS for stream processing jobs.
*   As an Operator, I want to customize configuration parameters for FLUSS components using a ConfigMap.
*   As an Operator, I want to upgrade the FLUSS deployment to a newer version with minimal downtime.

## 5. Requirements

### 5.1 Chart Structure & Metadata

*   Standard Helm chart structure (`Chart.yaml`, `values.yaml`, `templates/`, `crds/` if needed).
*   Clear metadata in `Chart.yaml` (name, version, appVersion, description, keywords, maintainers).
*   Well-documented default `values.yaml` with clear explanations for each parameter.
*   Use of helper templates (`_helpers.tpl`) for common labels, names, etc.

### 5.2 Core FLUSS Components

*   **Coordinator:**
    *   Deploy as a Kubernetes Deployment.
    *   Configurable replica count.
    *   Configurable resource requests/limits.
    *   Expose via a Kubernetes Service (ClusterIP by default).
    *   Support for custom annotations/labels.
    *   Liveness and readiness probes.
*   **Tablet Server:**
    *   Deploy as a Kubernetes StatefulSet (preferred for stable identity and storage) or Deployment.
    *   Configurable replica count.
    *   Configurable resource requests/limits.
    *   Expose via a Kubernetes Service (potentially Headless for direct pod access).
    *   Support for persistent storage (PVCs) if needed for local state (details TBD based on FLUSS architecture).
    *   Support for custom annotations/labels.
    *   Liveness and readiness probes.

### 5.3 Dependencies (Optional)

*   **ZooKeeper:**
    *   Option to enable/disable (`zookeeper.enabled`).
    *   If enabled: Deploy a ZooKeeper ensemble (StatefulSet recommended). Configurable replicas, resources, persistence (PVC).
    *   If disabled: Allow configuration of external ZooKeeper connection string.
*   **Flink:**
    *   Option to enable/disable (`flink.enabled`).
    *   If enabled: Deploy Flink JobManager (Deployment) and TaskManager (Deployment/StatefulSet). Configurable replicas, resources. Expose JobManager UI via Service/Ingress.
    *   Requires configuration pointing to the FLUSS cluster.
*   **MinIO (for Persistence):**
    *   Option to enable/disable (`minio.enabled`).
    *   If enabled: Deploy MinIO (Deployment/StatefulSet). Configurable resources, persistence (PVC). Create Secret for access keys. Expose via Service.
    *   Requires configuration in FLUSS components to use this MinIO instance.
    *   Option to configure external S3-compatible storage instead.

### 5.4 Configuration

*   Provide options to configure FLUSS via `values.yaml`.
*   Support mounting a custom configuration file via a ConfigMap (`configMap.enabled`, `configMap.name`).
*   Secrets management for sensitive data (e.g., MinIO keys, external ZK credentials).

### 5.5 Networking

*   Define appropriate Services for component communication.
*   Optionally configure Ingress resources for external access (e.g., Flink UI).

### 5.6 Security

*   Option to configure PodSecurityContext and SecurityContext for containers.
*   Option to configure ServiceAccounts.
*   RBAC configuration if necessary for components interacting with the Kubernetes API.

### 5.7 Persistence

*   Define options for persistence for ZooKeeper, MinIO, and potentially Tablet Servers (`persistence.enabled`, `persistence.storageClass`, `persistence.size`).

## 6. Open Questions

*   Does the FLUSS Tablet Server require persistent local storage, or does it rely solely on external systems (like MinIO/S3 via Coordinator)? This impacts whether StatefulSet+PVC is strictly needed for tablets.
*   What are the specific configuration parameters required by FLUSS Coordinator and Tablet Servers?
*   What are the default resource requirements for each component?
*   Are there specific CRDs required by FLUSS?
*   What are the exact mechanisms for coordination (ZK paths, etc.)?
*   How is Flink configured to connect to FLUSS?

## 7. Future Considerations

*   Helm test suites.
*   Autoscaling configurations (HPA).
*   Advanced monitoring integration (Prometheus metrics scraping).
*   Support for different cloud provider storage classes. 