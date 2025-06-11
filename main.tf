# main.tf

# Data source to get all integration instances in the compartment
data "oci_integration_integration_instances" "instances" {
  compartment_id = var.compartment_id
  state         = "ACTIVE"
}

# Create dashboard group only if dashboard_group_id is not provided
resource "oci_management_dashboard_management_dashboards_group" "integration_monitoring" {
  count = var.dashboard_group_id == "" ? 1 : 0
  
  compartment_id = var.compartment_id
  display_name   = var.dashboard_group_name
  description    = "Dashboard group for monitoring integration message pack overages"
}

# Local value to determine which dashboard group to use
locals {
  dashboard_group_id = var.dashboard_group_id != "" ? var.dashboard_group_id : oci_management_dashboard_management_dashboards_group.integration_monitoring[0].id
}

# Create BilledMessagePackCountOverage dashboard for each integration instance
resource "oci_management_dashboard_management_dashboard" "integration_overage_dashboard" {
  count = length(data.oci_integration_integration_instances.instances.integration_instances)

  compartment_id = var.compartment_id
  dashboard_id   = "integration-overage-${data.oci_integration_integration_instances.instances.integration_instances[count.index].id}"
  display_name   = "Message Pack Overage - ${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name}"
  description    = "Monitor billed message pack count overage for ${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name}"
  
  # Associate with dashboard group
  dashboard_group_id = local.dashboard_group_id

  # Dashboard configuration JSON
  config = jsonencode({
    version = "1.0"
    widgets = [
      {
        id   = "overage-widget-1"
        type = "metric-chart"
        title = "${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name} - Billed Message Pack Count Overage"
        position = {
          x = 0
          y = 0
          width = 12
          height = 6
        }
        configuration = {
          metricQuery = {
            namespace = "oci_integration"
            query = "BilledMessagePackCountOverage[1h]{resourceName=\"${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name}\"}.sum()"
            resolution = "1h"
          }
          chartType = "line"
          yAxis = {
            title = "Overage Count"
          }
          xAxis = {
            title = "Time"
          }
        }
      },
      {
        id   = "overage-widget-2"
        type = "metric-chart"
        title = "${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name} - Hourly Overage Rate"
        position = {
          x = 0
          y = 6
          width = 6
          height = 4
        }
        configuration = {
          metricQuery = {
            namespace = "oci_integration"
            query = "BilledMessagePackCountOverage[5m]{resourceName=\"${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name}\"}.rate()"
            resolution = "5m"
          }
          chartType = "area"
          yAxis = {
            title = "Overage Rate"
          }
          xAxis = {
            title = "Time"
          }
        }
      },
      {
        id   = "overage-widget-3"
        type = "single-value"
        title = "${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name} - Current Overage Status"
        position = {
          x = 6
          y = 6
          width = 6
          height = 4
        }
        configuration = {
          metricQuery = {
            namespace = "oci_integration"
            query = "BilledMessagePackCountOverage[5m]{resourceName=\"${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name}\"}.sum()"
            resolution = "5m"
          }
          unit = "count"
        }
      }
    ]
  })

  freeform_tags = merge(var.tags, {
    "Purpose" = "OverageMonitoring"
    "InstanceName" = data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name
  })
}

# Create BilledMessageCount dashboard for each integration instance
resource "oci_management_dashboard_management_dashboard" "integration_count_dashboard" {
  count = length(data.oci_integration_integration_instances.instances.integration_instances)

  compartment_id = var.compartment_id
  dashboard_id   = "integration-count-${data.oci_integration_integration_instances.instances.integration_instances[count.index].id}"
  display_name   = "Message Count - ${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name}"
  description    = "Monitor billed message count for ${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name}"
  
  # Associate with dashboard group
  dashboard_group_id = local.dashboard_group_id

  # Dashboard configuration JSON
  config = jsonencode({
    version = "1.0"
    widgets = [
      {
        id   = "count-widget-1"
        type = "metric-chart"
        title = "${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name} - Billed Message Count"
        position = {
          x = 0
          y = 0
          width = 12
          height = 6
        }
        configuration = {
          metricQuery = {
            namespace = "oci_integration"
            query = "BilledMessageCount[1h]{resourceId=\"${data.oci_integration_integration_instances.instances.integration_instances[count.index].id}\"}.sum()"
            resolution = "1h"
          }
          chartType = "line"
          yAxis = {
            title = "Message Count"
          }
          xAxis = {
            title = "Time"
          }
        }
      },
      {
        id   = "count-widget-2"
        type = "metric-chart"
        title = "${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name} - Message Rate"
        position = {
          x = 0
          y = 6
          width = 6
          height = 4
        }
        configuration = {
          metricQuery = {
            namespace = "oci_integration"
            query = "BilledMessageCount[5m]{resourceId=\"${data.oci_integration_integration_instances.instances.integration_instances[count.index].id}\"}.rate()"
            resolution = "5m"
          }
          chartType = "area"
          yAxis = {
            title = "Messages per Second"
          }
          xAxis = {
            title = "Time"
          }
        }
      },
      {
        id   = "count-widget-3"
        type = "single-value"
        title = "${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name} - Current Message Count"
        position = {
          x = 6
          y = 6
          width = 6
          height = 4
        }
        configuration = {
          metricQuery = {
            namespace = "oci_integration"
            query = "BilledMessageCount[5m]{resourceId=\"${data.oci_integration_integration_instances.instances.integration_instances[count.index].id}\"}.sum()"
            resolution = "5m"
          }
          unit = "count"
        }
      }
    ]
  })

  freeform_tags = merge(var.tags, {
    "Purpose" = "MessageCountMonitoring"
    "InstanceName" = data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name
  })
}

# Create alarms for message pack overages
resource "oci_monitoring_alarm" "message_pack_overage_alarm" {
  count = length(data.oci_integration_integration_instances.instances.integration_instances)

  compartment_id = var.compartment_id
  display_name   = "Message Pack Overage - ${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name}"
  description    = "Alert when message pack overage occurs for ${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name}"
  
  is_enabled = true
  severity   = var.alarm_severity
  
  # Alarm condition using the correct metric and resource name
  query = "BilledMessagePackCountOverage[5m]{resourceName=\"${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name}\"}.sum() > 0"
  
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

# Create a summary dashboard showing all instances
resource "oci_management_dashboard_management_dashboard" "integration_summary_dashboard" {
  compartment_id = var.compartment_id
  dashboard_id   = "integration-summary-dashboard"
  display_name   = "Integration Summary - All Instances"
  description    = "Summary view of message pack usage across all integration instances"
  
  dashboard_group_id = local.dashboard_group_id

  config = jsonencode({
    version = "1.0"
    widgets = [
      {
        id   = "summary-widget-1"
        type = "metric-chart"
        title = "Total Message Pack Overages (All Instances)"
        position = {
          x = 0
          y = 0
          width = 12
          height = 6
        }
        configuration = {
          metricQuery = {
            namespace = "oci_integration"
            query = "BilledMessagePackCountOverage[1h]{compartmentId=\"${var.compartment_id}\"}.groupBy(resourceName).sum()"
            resolution = "1h"
          }
          chartType = "stacked-area"
          yAxis = {
            title = "Overage Count"
          }
          xAxis = {
            title = "Time"
          }
        }
      },
      {
        id   = "summary-widget-2"
        type = "metric-chart"
        title = "Total Billed Message Count (All Instances)"
        position = {
          x = 0
          y = 6
          width = 12
          height = 6
        }
        configuration = {
          metricQuery = {
            namespace = "oci_integration"
            query = "BilledMessageCount[1h]{compartmentId=\"${var.compartment_id}\"}.groupBy(resourceDisplayName).sum()"
            resolution = "1h"
          }
          chartType = "stacked-area"
          yAxis = {
            title = "Message Count"
          }
          xAxis = {
            title = "Time"
          }
        }
      }
    ]
  })

  freeform_tags = merge(var.tags, {
    "Purpose" = "Summary"
  })
}
