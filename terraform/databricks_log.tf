resource "azurerm_monitor_diagnostic_setting" "dbk_log" {
  name                       = "${var.environment}-${var.project}-log-dbk"
  target_resource_id         = azurerm_databricks_workspace.dbk.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id

  enabled_log {
    category = "clusters"
  }

  enabled_log {
    category = "jobs"
  }

  enabled_log {
    category = "workspace"
  }

  enabled_log {
    category = "dbfs"
  }

  enabled_log {
    category = "notebook"
  }

  enabled_log {
    category = "accounts"
  }

  enabled_log {
    category = "secrets"
  }

  enabled_log {
    category = "repos"
  }

  enabled_log {
    category = "gitCredentials"
  }

  enabled_log {
    category = "databrickssql"
  }

}