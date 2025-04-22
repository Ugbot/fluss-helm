#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.
# set -u # Treat unset variables as an error.
# set -o pipefail # Causes a pipeline to return the exit status of the last command in the pipe that returned a non-zero return value.

# Ensure we are in the correct directory relative to the script
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd "$SCRIPT_DIR/.." # Move up to the workspace root

RELEASE_NAME="test-install-defaults"
CHART_PATH="./fluss-helm-chart"
NAMESPACE="default" # Consider using a dedicated test namespace
WAIT_TIMEOUT="5m"

# --- Helper Functions --- 
cleanup() {
  echo "--- Cleaning Up Helm Release (Defaults) --- "
  helm uninstall "${RELEASE_NAME}" --namespace "${NAMESPACE}" --wait --timeout "${WAIT_TIMEOUT}" || echo "Release ${RELEASE_NAME} not found or already cleaned up."
  echo "--- Cleanup Attempted --- "
}

check_pods_ready() {
    local namespace="$1"
    local release_name="$2"
    local timeout_seconds=300 # 5 minutes
    local interval_seconds=10
    local end_time=$((SECONDS + timeout_seconds))

    echo "Waiting for pods in release ${release_name} to be ready..."

    while [ $SECONDS -lt $end_time ]; do
        local not_ready_pods=$(kubectl get pods -n "${namespace}" -l "app.kubernetes.io/instance=${release_name}" -o jsonpath='{range .items[*]}{.metadata.name}{":"}{.status.phase}{" "}{end}' | grep -v "Running" | grep -v "Succeeded" || true)
        
        if [ -z "${not_ready_pods}" ]; then
            echo "All pods are ready."
            return 0 # Success
        fi

        echo "Waiting for pods: ${not_ready_pods}"
        sleep $interval_seconds
    done

    echo "Timeout waiting for pods to become ready." >&2
    kubectl get pods -n "${namespace}" -l "app.kubernetes.io/instance=${release_name}" # Print final status
    return 1 # Failure
}

# --- Main Test Logic --- 

# Trap ensures cleanup runs even if the script exits unexpectedly
trap cleanup EXIT ERR

echo "--- Running Helm Install (Defaults) for ${CHART_PATH} --- "
# Attempt cleanup first in case a previous run failed mid-way
cleanup 

helm install "${RELEASE_NAME}" "${CHART_PATH}" --namespace "${NAMESPACE}" --wait --timeout "${WAIT_TIMEOUT}"

echo "--- Helm Install (Defaults) Successful --- "

echo "--- Performing Basic Checks (Defaults) --- "

# Check rollout status of deployments/statefulsets
kubectl rollout status deployment "${RELEASE_NAME}-fluss-coordinator" -n "${NAMESPACE}" --timeout=3m
kubectl rollout status statefulset "${RELEASE_NAME}-fluss-tablet" -n "${NAMESPACE}" --timeout=3m
kubectl rollout status deployment "${RELEASE_NAME}-fluss-zookeeper" -n "${NAMESPACE}" --timeout=3m

# Optionally use the pod ready check function
# check_pods_ready "${NAMESPACE}" "${RELEASE_NAME}"

echo "--- Basic Checks Complete --- "

# Cleanup is handled by the trap
echo "--- Test Install (Defaults) Complete --- "

# Explicitly exit successfully after trap cleanup runs
exit 0 