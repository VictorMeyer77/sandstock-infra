resource "azurerm_automation_runbook" "test" {
  name                    = "test"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.aut.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This is an example runbook"
  runbook_type            = "Python3"
  content                 = "print('Launch source control synchronisation to update runbooks.')"
}