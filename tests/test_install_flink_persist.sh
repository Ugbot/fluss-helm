#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# Ensure we are in the correct directory relative to the script
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd "$SCRIPT_DIR/.." # Move up to the workspace root

RELEASE_NAME="test-install-fp"
CHART_PATH="./fluss-helm-chart"
NAMESPACE="default" # Consider using a dedicated test namespace
WAIT_TIMEOUT="5m"

# --- Helper Functions --- 
cleanup() {
  echo "--- Cleaning Up Helm Release (Flink+Persistence) --- "
  helm uninstall "${RELEASE_NAME}" --namespace "${NAMESPACE}" --wait --timeout "${WAIT_TIMEOUT}" || echo "Release ${RELEASE_NAME} not found or already cleaned up."
  # Consider cleaning up PVCs manually if ReclaimPolicy is Retain
  # kubectl delete pvc -n "${NAMESPACE}" -l "app.kubernetes.io/instance=${RELEASE_NAME},component=minio"
  # kubectl delete pvc -n "${NAMESPACE}" -l "app.kubernetes.io/instance=${RELEASE_NAME},component=zookeeper"
  echo "--- Cleanup Attempted --- "
}

# --- Main Test Logic --- 

trap cleanup EXIT ERR

echo "--- Running Helm Install (Flink + Persistence) for ${CHART_PATH} --- "
echo "NOTE: This test requires a suitable StorageClass in the cluster."
# Attempt cleanup first
cleanup

# --- INSTALL COMMAND --- 
# Add --set minio.persistence.storageClass=... if required by your cluster
# Add --set zookeeper.persistence.enabled=true and --set zookeeper.persistence.storageClass=... to test ZK persistence
helm install "${RELEASE_NAME}" "${CHART_PATH}" --namespace "${NAMESPACE}" \
  --set enableFlink=true \
  --set usePersistence=true \
  --wait --timeout "${WAIT_TIMEOUT}"
# ----------------------

echo "--- Helm Install (Flink + Persistence) Successful --- "

echo "--- Performing Basic Checks (Flink + Persistence) --- "

# Check rollout status for all expected components
kubectl rollout status deployment "${RELEASE_NAME}-fluss-coordinator" -n "${NAMESPACE}" --timeout=3m
kubectl rollout status statefulset "${RELEASE_NAME}-fluss-tablet" -n "${NAMESPACE}" --timeout=3m
kubectl rollout status deployment "${RELEASE_NAME}-fluss-zookeeper" -n "${NAMESPACE}" --timeout=3m
kubectl rollout status deployment "${RELEASE_NAME}-flink-jobmanager" -n "${NAMESPACE}" --timeout=3m
kubectl rollout status deployment "${RELEASE_NAME}-flink-taskmanager" -n "${NAMESPACE}" --timeout=3m
kubectl rollout status deployment "${RELEASE_NAME}-minio" -n "${NAMESPACE}" --timeout=3m

# Check PVCs were created
echo "Checking for PVCs..."
kubectl get pvc -n "${NAMESPACE}" -l "app.kubernetes.io/instance=${RELEASE_NAME},component=minio"
# Add check for ZK PVC if zookeeper.persistence.enabled was set to true during install
# kubectl get pvc -n "${NAMESPACE}" -l "app.kubernetes.io/instance=${RELEASE_NAME},component=zookeeper"

echo "--- Basic Checks Complete --- "

# Cleanup is handled by the trap
echo "--- Test Install (Flink + Persistence) Complete --- "

exit 0 