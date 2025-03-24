resource "azurerm_automation_runbook" "rotate_service_principal" {
  name                    = "rotate_service_principal"
  location                = azurerm_resource_group.rg_aut.location
  resource_group_name     = azurerm_resource_group.rg_aut.name
  automation_account_name = azurerm_automation_account.aut.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "Rotate an application service principal secret"
  runbook_type            = "Python3"
  content                 = "print('Launch source control synchronisation to update runbooks.')"

  job_schedule {
    schedule_name = azurerm_automation_schedule.rotate_dbk_app_secret.name
    parameters = {
      "json" : "{\\\"sp\\\":\\\"${azuread_service_principal.dbk_app_sp.id}\\\",\\\"kv_name\\\":\\\"${azurerm_key_vault.kv.name}\\\",\\\"kv_secret_name\\\":\\\"${azurerm_key_vault_secret.dbk_app_client_secret.name}\\\",\\\"app_name\\\":\\\"${azuread_application.dbk_app.display_name}\\\",\\\"rotation_days\\\":29}"
    }
  }
}