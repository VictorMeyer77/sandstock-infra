resource "azurerm_role_assignment" "adf_blob_role" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.adf.identity[0].principal_id
}

resource "azurerm_role_assignment" "adf_dbk_role" {
  scope                = azurerm_databricks_workspace.dbk.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_data_factory.adf.identity[0].principal_id
}

resource "azurerm_role_assignment" "dbk_blob_role" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.dbk_app_sp.object_id
}

resource "azurerm_role_assignment" "aut_role" {
  scope                = azurerm_automation_account.aut.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_automation_account.aut.identity[0].principal_id
}
