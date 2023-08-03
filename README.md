
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes - Pod status not ready
---

This incident type occurs when a Kubernetes pod is not ready to accept traffic due to a configuration problem or a change in the pod specification. It can cause spikes in the number of unavailable pods and impact the performance of the system.

### Parameters
```shell
# Environment Variables
export POD_NAMESPACE="PLACEHOLDER"
export POD_NAME="PLACEHOLDER"
export CONTAINER_NAME="PLACEHOLDER"
export MAXIMUM_AMOUNT_OF_THE_RESOURCE="PLACEHOLDER"
export NAME_OF_THE_RESOURCE_TO_CHECK="PLACEHOLDER"
```

## Debug

### List all pods in namespace.
```shell
kubectl get pods -n ${POD_NAMESPACE}
```

### Check the status of a specific pod.
```shell
kubectl describe pod ${POD_NAME} -n ${POD_NAMESPACE}
```

### Get logs from a specific container  in pod.
```shell
kubectl logs ${POD_NAME} -c ${CONTAINER_NAME} -n ${POD_NAMESPACE}
```

### Check the events related to a specific pod.
```shell
kubectl get events --field-selector involvedObject.name=${POD_NAME} -n ${POD_NAMESPACE}
```
### Check the status of all persistent volume claims in namespace.

```shell
kubectl get pvc -n ${POD_NAMESPACE}
```

### Configuration errors or misconfigurations in the pod
```shell
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

```
---

## Repair
---
### Increase the resources allocated to the pod if it is running out of memory or CPU.
```shell

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

```
---