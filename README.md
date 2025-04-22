# FLUSS Helm Chart

This chart deploys the FLUSS streaming layer on Kubernetes.

## Prerequisites

*   Kubernetes 1.19+
*   Helm 3.2+

## Installation

```bash
helm repo add fluss <repository-url>  # Add the repo (replace <repository-url>)
helm repo update
helm install my-fluss fluss/fluss-helm-chart --version <chart-version>
```

## Configuration

The following table lists the configurable parameters of the FLUSS chart and their default values.

| Parameter                   | Description                                       | Default          |
| --------------------------- | ------------------------------------------------- | ---------------- |
| `replicaCount`              | Number of FLUSS Coordinator replicas              | `1`              |
| `image.repository`          | FLUSS image repository                            | `fluss/fluss`    |
| `image.pullPolicy`          | Image pull policy                                 | `IfNotPresent`   |
| `image.tag`                 | Image tag (defaults to chart's appVersion)        | ``               |
| `service.type`              | Kubernetes service type for Coordinator           | `ClusterIP`      |
| `service.port`              | Kubernetes service port for Coordinator           | `8080`           |
| `tablet.replicaCount`       | Number of FLUSS Tablet Server replicas            | `3`              |
| `tablet.image.repository`   | Tablet Server image repository                    | `fluss/fluss`    |
| `tablet.image.tag`          | Tablet Server image tag                           | ``               |
| `zookeeper.enabled`         | Deploy a bundled ZooKeeper                        | `true`           |
| `zookeeper.replicaCount`    | Number of ZooKeeper replicas                      | `3`              |
| `zookeeper.external.servers`| List of external ZooKeeper servers (if not enabled) | `[]`             |
| `flink.enabled`             | Deploy a bundled Flink cluster                    | `false`          |
| `minio.enabled`             | Deploy bundled MinIO for persistence              | `false`          |
| `persistence.enabled`       | Enable persistence using MinIO/S3                 | `false`          |
| `persistence.useBundledMinio` | Use the bundled Minio if `minio.enabled` is true | `true`           |
| `persistence.externalS3.*`  | Configuration for external S3-compatible storage  | `{}`             |
| `configMap.enabled`         | Use a custom ConfigMap for FLUSS configuration    | `false`          |
| `configMap.name`            | Name of the existing ConfigMap to use             | ``               |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

For example:

```bash
helm install my-fluss fluss/fluss-helm-chart \
  --set tablet.replicaCount=5 \
  --set persistence.enabled=true \
  --set minio.enabled=true
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example:

```bash
helm install my-fluss fluss/fluss-helm-chart -f values.yaml
```

## Components

*   **Coordinator:** Manages cluster state, metadata, and coordinates Tablet Servers.
*   **Tablet Server:** Stores and serves stream data partitions (tablets).
*   **ZooKeeper:** (Optional) Used for coordination and leader election.
*   **Flink:** (Optional) Apache Flink cluster for running stream processing jobs.
*   **MinIO:** (Optional) S3-compatible object storage for persistent state.

## Contributing

[Details on contributing guidelines]

## License

[Specify the license, e.g., Apache 2.0] 