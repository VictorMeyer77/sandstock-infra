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
  connection_string        = "data source=${azurerm_mssql_server.sql_server.fully_qualified_domain_name},1433;initial catalog=${azurerm_mssql_database.erp_db.name};user id=sql_admin;Password=${var.sql_db_admin_password};integrated security=False;encrypt=True;connection timeout=30"
  integration_runtime_name = azurerm_data_factory_integration_runtime_azure.adf_runtime.name
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "adf_sto" {
  name                     = "${var.environment}-${var.project}-adf-sto"
  data_factory_id          = azurerm_data_factory.adf.id
  integration_runtime_name = azurerm_data_factory_integration_runtime_azure.adf_runtime.name
  service_endpoint         = azurerm_storage_account.storage.primary_blob_endpoint

  use_managed_identity = true

}

# Datasets

resource "azurerm_data_factory_dataset_azure_sql_table" "erp_tables" {
  name              = "${var.environment}-${var.project}-erp-tables"
  data_factory_id   = azurerm_data_factory.adf.id
  linked_service_id = azurerm_data_factory_linked_service_azure_sql_database.adf_sql.id
  schema            = azurerm_mssql_database.erp_db.name
}