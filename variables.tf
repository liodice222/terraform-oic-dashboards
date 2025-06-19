


variable "compartment_id" {
  description = "OCID of the compartment containing integration instances"
  type        = string
}

variable "dashboard_group_id" {
  description = "OCID of an existing dashboard group (will create new group if not provided)"
  type        = string
  default     = ""
}

variable "dashboard_group_name" {
  description = "Name for the dashboard group"
  type        = string
  default     = "OIC Message Pack Overage Monitoring"
}

variable "notification_topic_id" {
  description = "OCID of the notification topic for alarms for message pack overage"
  type        = string
  default     = ""
}

variable "alarm_severity" {
  description = "Severity level for message pack overage alarms"
  type        = string
  default     = "WARNING"
  validation {
    condition     = contains(["CRITICAL", "ERROR", "WARNING", "INFO"], var.alarm_severity)
    error_message = "Alarm severity must be one of: CRITICAL, ERROR, WARNING, INFO."
  }
}

variable "alarm_pending_duration" {
  description = "Duration to wait before triggering alarm "
  type        = string
  default     = "PT5M"
}

variable "metric_resolution" {
  description = "Resolution for metrics collection"
  type        = string
  default     = "5m"
  validation {
    condition     = contains(["1m", "5m", "1h"], var.metric_resolution)
    error_message = "Metric resolution must be one of: 1m, 5m, 1h."
  }
}


