resource "azurerm_data_factory_linked_service_azure_sql_database" "adf_sql" {
  name                     = "${var.environment}-${var.project}-adf-sql"
  data_factory_id          = azurerm_data_factory.adf.id
  integration_runtime_name = azurerm_data_factory_integration_runtime_azure.adf_runtime.name

  connection_string = "Server=tcp:${azurerm_mssql_server.sql_server.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.erp_db.name};User ID=sql_admin;Encrypt=True;Connection Timeout=30;"

  key_vault_password {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.adf_kv.name
    secret_name         = azurerm_key_vault_secret.db_usr_pwd.name
  }
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "adf_sto" {
  name                     = "${var.environment}-${var.project}-adf-sto"
  data_factory_id          = azurerm_data_factory.adf.id
  integration_runtime_name = azurerm_data_factory_integration_runtime_azure.adf_runtime.name
  url                      = azurerm_storage_account.storage.primary_dfs_endpoint
  use_managed_identity     = true
}

resource "azurerm_data_factory_linked_service_key_vault" "adf_kv" {
  name                     = "${var.environment}-${var.project}-adf-kv"
  data_factory_id          = azurerm_data_factory.adf.id
  key_vault_id             = azurerm_key_vault.kv.id
  integration_runtime_name = azurerm_data_factory_integration_runtime_azure.adf_runtime.name
}

resource "azurerm_data_factory_linked_service_azure_databricks" "adf_dbk" {
  name                       = "${var.environment}-${var.project}-adf-dbk"
  data_factory_id            = azurerm_data_factory.adf.id
  adb_domain                 = "https://${azurerm_databricks_workspace.dbk.workspace_url}"
  msi_work_space_resource_id = azurerm_databricks_workspace.dbk.id
  existing_cluster_id        = databricks_cluster.shared_autoscaling.cluster_id
  integration_runtime_name = azurerm_data_factory_integration_runtime_azure.adf_runtime.name

  depends_on = [
    databricks_cluster.shared_autoscaling
  ]
}
