#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "=== Starting Helm Chart Test Suite ==="

# Get the directory where the script resides
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# --- Static Tests --- 

echo
echo "*** Running Lint Test ***"
bash "${SCRIPT_DIR}/test_lint.sh"
if [ $? -ne 0 ]; then echo "Lint Test Failed!" >&2; exit 1; fi
echo "*** Lint Test Passed ***"

echo
echo "*** Running Template Defaults Test ***"
bash "${SCRIPT_DIR}/test_template_defaults.sh"
if [ $? -ne 0 ]; then echo "Template Defaults Test Failed!" >&2; exit 1; fi
echo "*** Template Defaults Test Passed ***"

echo
echo "*** Running Template Flink+Persistence Test ***"
bash "${SCRIPT_DIR}/test_template_flink_persist.sh"
if [ $? -ne 0 ]; then echo "Template Flink+Persistence Test Failed!" >&2; exit 1; fi
echo "*** Template Flink+Persistence Test Passed ***"

echo
echo "*** Running Template ConfigMap Test ***"
bash "${SCRIPT_DIR}/test_template_configmap.sh"
if [ $? -ne 0 ]; then echo "Template ConfigMap Test Failed!" >&2; exit 1; fi
echo "*** Template ConfigMap Test Passed ***"

echo
echo "*** Running Dry Run Test ***"
bash "${SCRIPT_DIR}/test_dry_run.sh"
if [ $? -ne 0 ]; then echo "Dry Run Test Failed!" >&2; exit 1; fi
echo "*** Dry Run Test Passed ***"

# --- Installation Tests (Optional) --- 

echo
read -p "Run installation tests (requires configured kubectl and potentially StorageClass)? [y/N] " -n 1 -r
echo # Move to a new line

if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo
    echo "*** Running Install Defaults Test ***"
    bash "${SCRIPT_DIR}/test_install_defaults.sh"
    if [ $? -ne 0 ]; then echo "Install Defaults Test Failed!" >&2; exit 1; fi
    echo "*** Install Defaults Test Passed ***"
    
    echo
    echo "*** Running Install Flink+Persistence Test ***"
    bash "${SCRIPT_DIR}/test_install_flink_persist.sh"
    if [ $? -ne 0 ]; then echo "Install Flink+Persistence Test Failed!" >&2; exit 1; fi
    echo "*** Install Flink+Persistence Test Passed ***"
else
    echo
    echo "--- Skipping installation tests. ---"
fi

echo
echo "=== Helm Chart Test Suite Complete ==="
exit 0 