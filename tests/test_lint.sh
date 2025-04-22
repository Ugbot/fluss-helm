#!/bin/bash
set -e # Exit on error

# Ensure we are in the correct directory relative to the script
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd "$SCRIPT_DIR/.." # Move up to the workspace root

CHART_PATH="./fluss-helm-chart"

echo "--- Running Helm Lint on ${CHART_PATH} --- "
helm lint "${CHART_PATH}"

echo "--- Helm Lint Successful ---" 