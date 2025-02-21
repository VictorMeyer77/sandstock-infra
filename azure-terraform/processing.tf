resource "azurerm_data_factory" "adf" {
  name                            = "${var.environment}-${var.project}-adf"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  managed_virtual_network_enabled = true
}

resource "azurerm_data_factory_integration_runtime_azure" "adf_runtime" {
  name                    = "${var.environment}-${var.project}-runtime"
  data_factory_id         = azurerm_data_factory.adf.id
  location                = azurerm_resource_group.rg.location
  compute_type            = "General"
  core_count              = 8
  virtual_network_enabled = true
  time_to_live_min        = 10
}


resource "azurerm_data_factory_managed_private_endpoint" "adf_to_sql" {
  name               = "${var.environment}-${var.project}-adf-to-sql"
  data_factory_id    = azurerm_data_factory.adf.id
  target_resource_id = azurerm_mssql_server.sql_server.id
  subresource_name   = "sqlServer"

  depends_on = [
    azurerm_data_factory.adf
  ]
}

#resource "azurerm_data_factory_linked_service_key_vault" "adf_kv" {
#  name            = "${var.environment}-${var.project}-adf-kv"
#  data_factory_id = azurerm_data_factory.adf.id
#  key_vault_id    = azurerm_key_vault.kv.id
#}
#
#
#resource "azurerm_data_factory_linked_service_azure_sql_database" "adf_sql" {
#  name              = "${var.environment}-${var.project}-adf-sql"
#  data_factory_id   = azurerm_data_factory.adf.id
#  connection_string = "Server=tcp:${azurerm_mssql_server.sql_server.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.erp_db.name};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
#
#  key_vault_password {
#    linked_service_name = azurerm_data_factory_linked_service_key_vault.adf_kv.name
#    secret_name         = azurerm_key_vault_secret.kv_db_password.name
#  }
#
#}