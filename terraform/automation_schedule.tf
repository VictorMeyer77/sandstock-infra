resource "azurerm_automation_schedule" "rotate_dbk_app_secret" {
  name                    = "${var.environment}-${var.project}-sch-rot-dbk"
  resource_group_name     = azurerm_resource_group.rg_aut.name
  automation_account_name = azurerm_automation_account.aut.name
  frequency               = "Day"
  interval                = 29
  timezone                = "Etc/UTC"
  description             = "Schedule rotate Databricks Application secret every 29 days."
}