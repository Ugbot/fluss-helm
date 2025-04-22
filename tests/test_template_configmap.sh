#!/bin/bash
set -e # Exit on error

# Ensure we are in the correct directory relative to the script
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd "$SCRIPT_DIR/.." # Move up to the workspace root

CHART_PATH="./fluss-helm-chart"
RELEASE_NAME="test-release-cm"
OUTPUT_FILE="tests/template-output-configmap.yaml"

echo "--- Running Helm Template (ConfigMap) for ${CHART_PATH} --- "
helm template "${RELEASE_NAME}" "${CHART_PATH}" \
  --set useConfigMap=true \
  > "${OUTPUT_FILE}"

echo "--- Helm Template (ConfigMap) Successful ---"
echo "Output saved to ${OUTPUT_FILE}"

# Optional: Check for ConfigMap resource
# if ! grep -q 'kind: ConfigMap' "${OUTPUT_FILE}"; then
#   echo "Error: ConfigMap template missing ConfigMap resource" >&2
#   exit 1
# fi
# if ! grep -q 'name: FLUSS_CONFIG' "${OUTPUT_FILE}"; then
#    echo "Error: ConfigMap template did not set FLUSS_CONFIG env" >&2
#    exit 1
# fi 