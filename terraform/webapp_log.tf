resource "azurerm_monitor_diagnostic_setting" "svp_log" {
  name                       = "${var.environment}-${var.project}-log-svp"
  target_resource_id         = azurerm_service_plan.svp.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id

  metric {
    category = "AllMetrics"
  }

}

resource "azurerm_monitor_diagnostic_setting" "wap_log" {
  name                       = "${var.environment}-${var.project}-log-wap"
  target_resource_id         = azurerm_linux_web_app.erp.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_log {
    category = "AppServiceAuditLogs"
  }

  enabled_log {
    category = "AppServiceAuthenticationLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceIPSecAuditLogs"
  }

  metric {
    category = "AllMetrics"
  }

}