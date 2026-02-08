#!/bin/bash
# Mojito Helm Chart - Quick Start Deployment Script

set -e

# Configuration
RELEASE_NAME="mojito"
CHART_PATH="./helm/mojito"
ENVIRONMENT=${1:-development}
NAMESPACE=${2:-default}

echo "==========================================="
echo "Mojito Helm Chart Deployment"
echo "==========================================="
echo "Release Name: $RELEASE_NAME"
echo "Environment: $ENVIRONMENT"
echo "Namespace: $NAMESPACE"
echo "Chart Path: $CHART_PATH"
echo ""

# Validate chart
echo "Validating Helm chart..."
helm lint "$CHART_PATH"

# Check if release exists
if helm list -n "$NAMESPACE" | grep -q "$RELEASE_NAME"; then
    echo "Release '$RELEASE_NAME' already exists. Upgrading..."
    helm upgrade "$RELEASE_NAME" "$CHART_PATH" \
        -n "$NAMESPACE" \
        -f "$CHART_PATH/values-$ENVIRONMENT.yaml" \
        --wait
else
    echo "Creating new release '$RELEASE_NAME'..."
    helm install "$RELEASE_NAME" "$CHART_PATH" \
        -n "$NAMESPACE" \
        -f "$CHART_PATH/values-$ENVIRONMENT.yaml" \
        --wait
fi

echo ""
echo "==========================================="
echo "Deployment Complete!"
echo "==========================================="
echo ""

# Display deployment info
echo "Checking deployment status..."
kubectl get all -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME"

echo ""
echo "To access the application:"
echo "  kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME-api 8080:8080"
echo ""
echo "To view logs:"
echo "  kubectl logs -n $NAMESPACE -l app.kubernetes.io/instance=$RELEASE_NAME,app.kubernetes.io/component=api"
echo ""
echo "To get deployment notes:"
echo "  helm get notes $RELEASE_NAME -n $NAMESPACE"
echo ""
