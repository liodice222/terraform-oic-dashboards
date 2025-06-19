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
          width = 24
          height = 6
        }
        configuration = {
          metricQuery = {
            namespace = "oci_integration"
            query = "BilledMessagePackCountOverage[1h]{resourceName=\"${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name}\"}.max()"
            resolution = "1h"
          }
          chartType = "bar"
          yAxis = {
            title = "Overage Count"
          }
          xAxis = {
            title = "Time"
          }
        }
      },
      {
        id   = "count-widget-1"
        type = "metric-chart"
        title = "${data.oci_integration_integration_instances.instances.integration_instances[count.index].display_name} - Billed Message Count"
        position = {
          x = 0
          y = 6
          width = 24
          height = 6
        }
        configuration = {
          metricQuery = {
            namespace = "oci_integration"
            query = "BilledMessageCount[1h]{resourceId=\"${data.oci_integration_integration_instances.instances.integration_instances[count.index].id}\"}.sum()"
            resolution = "1h"
          }
          chartType = "bar"
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
          width = 24
          height = 6
        }
        configuration = {
          metricQuery = {
            namespace = "oci_integration"
            query = "BilledMessageCount[1h]{resourceId=\"${data.oci_integration_integration_instances.instances.integration_instances[count.index].id}\"}.sum()"
            resolution = "1h"
          }
          chartType = "bar"
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
          width = 24
          height = 6
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
          x = 0
          y = 0
          width = 24
          height = 6
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
          width = 24
          height = 6
        }
        configuration = {
          metricQuery = {
            namespace = "oci_integration"
            query = "BilledMessagePackCountOverage[1h]{compartmentId=\"${var.compartment_id}\"}.groupBy(resourceName).max()"
            resolution = "1h"
          }
          chartType = "bar"
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
          width = 24
          height = 6
        }
        configuration = {
          metricQuery = {
            namespace = "oci_integration"
            query = "BilledMessageCount[1h]{compartmentId=\"${var.compartment_id}\"}.groupBy(resourceDisplayName).sum()"
            resolution = "1h"
          }
          chartType = "bar"
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
