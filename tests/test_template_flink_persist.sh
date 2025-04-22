#!/bin/bash
set -e # Exit on error

# Ensure we are in the correct directory relative to the script
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd "$SCRIPT_DIR/.." # Move up to the workspace root

CHART_PATH="./fluss-helm-chart"
RELEASE_NAME="test-release-fp"
OUTPUT_FILE="tests/template-output-flink-persist.yaml"

echo "--- Running Helm Template (Flink + Persistence) for ${CHART_PATH} --- "
helm template "${RELEASE_NAME}" "${CHART_PATH}" \
  --set enableFlink=true \
  --set usePersistence=true \
  > "${OUTPUT_FILE}"

echo "--- Helm Template (Flink + Persistence) Successful ---"
echo "Output saved to ${OUTPUT_FILE}"

# Optional: Check for Flink/MinIO resources
# if ! grep -q 'component: flink-jobmanager' "${OUTPUT_FILE}"; then
#   echo "Error: Flink+Persistence template missing Flink JobManager" >&2
#   exit 1
# fi
# if ! grep -q 'component: minio' "${OUTPUT_FILE}"; then
#   echo "Error: Flink+Persistence template missing MinIO" >&2
#   exit 1
# fi 