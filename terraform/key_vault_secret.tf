resource "azurerm_key_vault_secret" "sql_srv_admin_pwd" {
  name         = "${azurerm_mssql_server.sql_server.name}-password"
  content_type = "Password of ${azurerm_mssql_server.sql_server.administrator_login} on azure sql ${azurerm_mssql_server.sql_server.name}"
  value        = random_password.sql_srv_admin_pwd.result
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [
    azurerm_key_vault_access_policy.tenant_kv_policy
  ]

}

resource "azurerm_key_vault_secret" "db_erp_usr_pwd" {
  name         = "${replace(azurerm_mssql_database.erp_db.name, "_", "-")}-db-password"
  content_type = "Password of ${local.erp_db_usr_name} on azure sql ${azurerm_mssql_database.erp_db.name}"
  value        = random_password.sql_erp_usr_pwd.result
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [
    azurerm_key_vault_access_policy.tenant_kv_policy
  ]

}

resource "azurerm_key_vault_secret" "dbk_app_client_secret" {
  name         = "${azuread_application.dbk_app.display_name}-secret"
  content_type = "Secret of ${azuread_application.dbk_app.display_name} application"
  value        = azuread_service_principal_password.dbk_app_sp_pwd.value
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [
    azurerm_key_vault_access_policy.tenant_kv_policy
  ]

}