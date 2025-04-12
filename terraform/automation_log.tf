resource "azurerm_monitor_diagnostic_setting" "aut_log" {
  name                       = "${var.environment}-${var.project}-log-aut"
  target_resource_id         = azurerm_automation_account.aut.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id

  enabled_log {
    category = "JobLogs"
  }

  enabled_log {
    category = "JobStreams"
  }

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
  }

}