resource "azurerm_log_analytics_workspace" "log" {
  name                = "${var.environment}-${var.project}-log"
  location            = azurerm_resource_group.rg_log.location
  resource_group_name = azurerm_resource_group.rg_log.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}