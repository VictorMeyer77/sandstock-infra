resource "azurerm_monitor_diagnostic_setting" "sto_log" {
  name                       = "${var.environment}-${var.project}-log-sto"
  target_resource_id         = azurerm_storage_account.storage.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id

  metric {
    category = "Transaction"
  }

}