
#!/bin/bash

# Define variables
POD=${POD_NAME}
NAMESPACE=${POD_NAMESPACE}
RESOURCE_NAME=${NAME_OF_THE_RESOURCE_TO_CHECK} # e.g. "cpu", "memory"
LIMIT=${MAXIMUM_AMOUNT_OF_THE_RESOURCE} # e.g. "500Mi", "2Gi", "1.5"

# Check the resource usage of the pod
POD_USAGE=$(kubectl top pods $POD -n $NAMESPACE --containers | awk '/'$POD'/{getline; print $3}')

# Check if the pod is running out of the specified resource
if [[ $(echo "$POD_USAGE $LIMIT" | awk '{print ($1/$2)*100}') -ge 90 ]]; then
    # If the pod is running out of resources, increase the limit for the specified resource
    kubectl set resources pod $POD -n $NAMESPACE --containers=<> --${RESOURCE_NAME}=${LIMIT}
    echo "Increased the resources allocated to $POD in $NAMESPACE"
else
    echo "$POD is not running out of $RESOURCE_NAME"
fi