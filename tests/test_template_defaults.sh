#!/bin/bash
set -e # Exit on error

# Ensure we are in the correct directory relative to the script
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd "$SCRIPT_DIR/.." # Move up to the workspace root

CHART_PATH="./fluss-helm-chart"
RELEASE_NAME="test-release-defaults"
OUTPUT_FILE="tests/template-output-defaults.yaml"

echo "--- Running Helm Template (Defaults) for ${CHART_PATH} --- "
helm template "${RELEASE_NAME}" "${CHART_PATH}" > "${OUTPUT_FILE}"

echo "--- Helm Template (Defaults) Successful ---"
echo "Output saved to ${OUTPUT_FILE}"

# Optional: Add checks here, e.g.
# if ! grep -q 'kind: Deployment' "${OUTPUT_FILE}"; then
#   echo "Error: Default template missing Deployment" >&2
#   exit 1
# fi 