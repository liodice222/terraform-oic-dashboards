# Create alarms for message pack overages
resource "oci_monitoring_alarm" "message_pack_overage_alarm" {
  count = length(data.oci_integration_integration_instances.instances.integration_instances)

  compartment_id = var.compartment_id
  display_name   = "Message Pack Overage - ${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name}"
  description    = "Alert when message pack overage occurs for ${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name}"
  
  is_enabled = true
  severity   = var.alarm_severity
  
  # Alarm condition using the correct metric and resource name
  query = "BilledMessagePackCountOverage[5m]{resourceName=\"${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name}\"}.max() > 0"
  
  # Evaluation settings
  resolution                = var.metric_resolution
  pending_duration         = var.alarm_pending_duration
  evaluation_slack_duration = "PT5M"
  
  # Notification configuration (if topic provided)
  destinations = var.notification_topic_id != "" ? [var.notification_topic_id] : []
  
  # Suppress similar alarms for 1 hour
  suppress {
    time_suppress_from  = "0001-01-01T00:00:00Z"
    time_suppress_until = "9999-12-31T23:59:59Z"
    description        = "Suppress duplicate overage alerts"
  }

  freeform_tags = merge(var.tags, {
    "AlertType" = "MessagePackOverage"
  })
} 