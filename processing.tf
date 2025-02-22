resource "azurerm_data_factory" "adf" {
  name                            = "${var.environment}-${var.project}-adf"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  managed_virtual_network_enabled = true

  identity {
    type = "SystemAssigned"
  }
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

# Linked Services

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

resource "azurerm_data_factory_linked_service_azure_blob_storage" "adf_sto" {
  name                     = "${var.environment}-${var.project}-adf-sto"
  data_factory_id          = azurerm_data_factory.adf.id
  integration_runtime_name = azurerm_data_factory_integration_runtime_azure.adf_runtime.name
  service_endpoint         = azurerm_storage_account.storage.primary_blob_endpoint

  use_managed_identity = true

}

resource "azurerm_data_factory_linked_service_key_vault" "adf_kv" {
  name                     = "${var.environment}-${var.project}-adf-kv"
  data_factory_id          = azurerm_data_factory.adf.id
  key_vault_id             = azurerm_key_vault.kv.id
  integration_runtime_name = azurerm_data_factory_integration_runtime_azure.adf_runtime.name
}

# Datasets

resource "azurerm_data_factory_dataset_azure_sql_table" "erp_tables" {
  name              = "${var.environment}_erp_tables"
  data_factory_id   = azurerm_data_factory.adf.id
  linked_service_id = azurerm_data_factory_linked_service_azure_sql_database.adf_sql.id
  schema            = azurerm_mssql_database.erp_db.name

  parameters = {
    tableName = ""
  }

  table = "@dataset().tableName"

}

resource "azurerm_data_factory_dataset_azure_blob" "sto_dataset" {
  name                = "${var.environment}_sto_dataset"
  data_factory_id     = azurerm_data_factory.adf.id
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.adf_sto.name


  path     = "@concat(dataset().container, '/', dataset().folderPath)"
  filename = "@dataset().fileName"

  parameters = {
    container  = "raw"
    folderPath = "folder/"
    fileName   = "file.csv"
  }
}