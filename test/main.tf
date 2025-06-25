resource "oci_management_dashboard_dashboard" "my_dash" {
  compartment_id   = var.free_compartment_ocid
  display_name     = "Runtime Overview"
  description      = "Key metrics for OIC instances"
  is_oob_dashboard = false
  metadata_version = "V2"

  widgets = [
    jsonencode({
      displayName = "CPU Utilisation"
      type        = "chart"
      dataConfig  = [
        {
          query = "CpuUtilization[1h].average()"
        }
      ]
    })
  ]
}
