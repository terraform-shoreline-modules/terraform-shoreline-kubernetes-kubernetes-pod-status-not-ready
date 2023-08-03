#!/bin/bash

# Define variables
NAMESPACE=${POD_NAMESPACE}
POD=${POD_NAME}

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl could not be found. Please install kubectl and try again."
    exit 1
fi

# Check if the pod is running
POD_STATUS=$(kubectl get pods "$POD" -n "$NAMESPACE" -o jsonpath='{.status.phase}')
if [[ "$POD_STATUS" != "Running" ]]; then
    echo "The pod $POD is not running. Its status is $POD_STATUS."
    exit 1
fi

# Check if the pod is ready
POD_READY=$(kubectl get pods "$POD" -n "$NAMESPACE" -o jsonpath='{.status.containerStatuses[0].ready}')
if [[ "$POD_READY" != "true" ]]; then
    echo "The pod $POD is not ready. Its readiness status is $POD_READY."
    exit 1
fi

# Check if the pod configuration is valid
POD_CONFIG=$(kubectl validate pod "$POD" -n "$NAMESPACE" 2>&1)
if [[ "$POD_CONFIG" != "pod \"$POD\" successfully validated" ]]; then
    echo "The pod $POD has a configuration error: $POD_CONFIG"
    exit 1
fi

echo "The pod $POD in namespace $NAMESPACE is running and ready with a valid configuration."
exit 0