#!/bin/bash
# Make Helm chart scripts executable

chmod +x helm/deploy.sh
chmod +x helm/uninstall.sh

echo "Scripts are now executable"
echo "Usage:"
echo "  ./helm/deploy.sh [environment] [namespace]"
echo "  ./helm/uninstall.sh [release-name] [namespace]"
