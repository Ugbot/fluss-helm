#!/bin/bash
set -e # Exit on error

# Ensure we are in the correct directory relative to the script
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd "$SCRIPT_DIR/.." # Move up to the workspace root

CHART_PATH="./fluss-helm-chart"
RELEASE_NAME="test-release-dry-run"

echo "--- Running Helm Install Dry Run (Defaults) for ${CHART_PATH} --- "
# Using --debug shows the rendered templates
helm install "${RELEASE_NAME}" "${CHART_PATH}" --dry-run --debug

echo "--- Helm Install Dry Run (Defaults) Successful ---" 