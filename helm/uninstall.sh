#!/bin/bash
# Mojito Helm Chart - Uninstall Script

set -e

RELEASE_NAME=${1:-mojito}
NAMESPACE=${2:-default}

echo "==========================================="
echo "Removing Mojito Helm Release"
echo "==========================================="
echo "Release Name: $RELEASE_NAME"
echo "Namespace: $NAMESPACE"
echo ""

read -p "Are you sure you want to uninstall '$RELEASE_NAME'? (yes/no) " -n 3 -r
echo ""
if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    helm uninstall "$RELEASE_NAME" -n "$NAMESPACE" --wait
    echo "Release '$RELEASE_NAME' has been uninstalled."
else
    echo "Uninstall cancelled."
fi
