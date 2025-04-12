resource "azurerm_monitor_diagnostic_setting" "erp_db_log" {
  name                       = "${var.environment}-${var.project}-log-erp"
  target_resource_id         = azurerm_mssql_database.erp_db.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id

  enabled_log {
    category = "Blocks"
  }

  enabled_log {
    category = "DatabaseWaitStatistics"
  }

  enabled_log {
    category = "Deadlocks"
  }

  enabled_log {
    category = "Errors"
  }

  enabled_log {
    category = "SQLInsights"
  }

  enabled_log {
    category = "Timeouts"
  }

  metric {
    category = "Basic"
  }

}