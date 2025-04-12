resource "azurerm_monitor_diagnostic_setting" "adf_log" {
  name                       = "${var.environment}-${var.project}-log-adf"
  target_resource_id         = azurerm_data_factory.adf.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id

  enabled_log {
    category = "ActivityRuns"
  }

  enabled_log {
    category = "PipelineRuns"
  }

  enabled_log {
    category = "TriggerRuns"
  }

  metric {
    category = "AllMetrics"
  }

}