resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "${var.environment}.${var.project}.sqlazure.database.azure.com"
  resource_group_name = azurerm_resource_group.rg_net.name
}

resource "azurerm_private_endpoint" "sql_pe" {
  name                = "${var.environment}-${var.project}-sql-pe"
  location            = azurerm_resource_group.rg_net.location
  resource_group_name = azurerm_resource_group.rg_net.name
  subnet_id           = azurerm_subnet.sql_subnet.id

  private_service_connection {
    name                           = "${var.environment}-${var.project}-sql-connection"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${var.environment}-${var.project}-sql-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql_dns.id]
  }
}

resource "azurerm_data_factory_managed_private_endpoint" "adf_sql_pe" {
  name               = "${var.environment}-${var.project}-adf-sql-pe"
  data_factory_id    = azurerm_data_factory.adf.id
  target_resource_id = azurerm_mssql_server.sql_server.id
  subresource_name   = "sqlServer"

  depends_on = [
    azurerm_data_factory.adf
  ]
}

resource "azurerm_data_factory_managed_private_endpoint" "adf_sto_pe" {
  name               = "${var.environment}-${var.project}-adf-sto-pe"
  data_factory_id    = azurerm_data_factory.adf.id
  target_resource_id = azurerm_storage_account.storage.id
  subresource_name   = "dfs"

  depends_on = [
    azurerm_data_factory.adf
  ]
}

resource "azurerm_data_factory_managed_private_endpoint" "adf_dbk_pe" {
  name               = "${var.environment}-${var.project}-adf-dbk-pe"
  data_factory_id    = azurerm_data_factory.adf.id
  target_resource_id = azurerm_databricks_workspace.dbk.id
  subresource_name   = "databricks_ui_api"

  depends_on = [
    azurerm_data_factory.adf
  ]
}

resource "azurerm_private_endpoint" "sto_dbk_pe" {
  name                = "${var.environment}-${var.project}-sto-dbk-pe"
  location            = azurerm_resource_group.rg_net.location
  resource_group_name = azurerm_resource_group.rg_net.name
  subnet_id           = azurerm_subnet.sto_dbk_subnet.id

  private_service_connection {
    name                           = "${var.environment}-${var.project}-sto-connection"
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["dfs"]
    is_manual_connection           = false
  }
}