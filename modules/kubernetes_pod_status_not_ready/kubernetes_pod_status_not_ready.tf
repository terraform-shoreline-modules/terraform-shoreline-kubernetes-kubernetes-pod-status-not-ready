resource "shoreline_notebook" "kubernetes_pod_status_not_ready" {
  name       = "kubernetes_pod_status_not_ready"
  data       = file("${path.module}/data/kubernetes_pod_status_not_ready.json")
  depends_on = [shoreline_action.invoke_pod_validation_check,shoreline_action.invoke_pod_resource_check]
}

resource "shoreline_file" "pod_validation_check" {
  name             = "pod_validation_check"
  input_file       = "${path.module}/data/pod_validation_check.sh"
  md5              = filemd5("${path.module}/data/pod_validation_check.sh")
  description      = "Configuration errors or misconfigurations in the pod"
  destination_path = "/agent/scripts/pod_validation_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "pod_resource_check" {
  name             = "pod_resource_check"
  input_file       = "${path.module}/data/pod_resource_check.sh"
  md5              = filemd5("${path.module}/data/pod_resource_check.sh")
  description      = "Increase the resources allocated to the pod if it is running out of memory or CPU."
  destination_path = "/agent/scripts/pod_resource_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_pod_validation_check" {
  name        = "invoke_pod_validation_check"
  description = "Configuration errors or misconfigurations in the pod"
  command     = "`chmod +x /agent/scripts/pod_validation_check.sh && /agent/scripts/pod_validation_check.sh`"
  params      = ["POD_NAME","POD_NAMESPACE"]
  file_deps   = ["pod_validation_check"]
  enabled     = true
  depends_on  = [shoreline_file.pod_validation_check]
}

resource "shoreline_action" "invoke_pod_resource_check" {
  name        = "invoke_pod_resource_check"
  description = "Increase the resources allocated to the pod if it is running out of memory or CPU."
  command     = "`chmod +x /agent/scripts/pod_resource_check.sh && /agent/scripts/pod_resource_check.sh`"
  params      = ["MAXIMUM_AMOUNT_OF_THE_RESOURCE","POD_NAME","POD_NAMESPACE","NAME_OF_THE_RESOURCE_TO_CHECK"]
  file_deps   = ["pod_resource_check"]
  enabled     = true
  depends_on  = [shoreline_file.pod_resource_check]
}

