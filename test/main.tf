provider "oci" {
  tenancy_ocid        = var.tenancy_ocid
  user_ocid           = var.user_ocid
  fingerprint         = var.fingerprint
  private_key_path    = var.private_key_path
  region              = var.region
}

resource "oci_management_dashboard_management_dashboards_group" "test_group" {
  compartment_id = var.compartment_id
  display_name   = "Test Dashboard Group"
  description    = "A group for testing dashboard widget sizing"
}

resource "oci_management_dashboard_management_dashboard" "test_dashboard" {
  compartment_id      = var.compartment_id
  dashboard_id        = "test-dashboard"
  display_name        = "Test Dashboard"
  description         = "A dashboard to test widget sizing"
  dashboard_group_id  = oci_management_dashboard_management_dashboards_group.test_group.id

  config = jsonencode({
    version = "1.0"
    widgets = [
      {
        id    = "test-widget-1"
        type  = "metric-chart"
        title = "Test Widget Full Width"
        position = {
          x      = 0
          y      = 0
          width  = 24   # Full width
          height = 6
        }
        configuration = {
          metricQuery = {
            namespace  = "oci_integration"
            query      = "BilledMessageCount[1h]{resourceId=\"test\"}.sum()"
            resolution = "1h"
          }
          chartType = "bar"
          yAxis = {
            title = "Test Y"
          }
          xAxis = {
            title = "Test X"
          }
        }
      }
    ]
  })
}
