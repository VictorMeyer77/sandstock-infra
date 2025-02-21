resource "azurerm_mssql_server" "sql_server" {
  name                          = "${var.environment}-${var.project}-sql"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "12.0"
  administrator_login           = "sql_admin"
  administrator_login_password  = var.sql_db_admin_password
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true
  tags                          = var.tags
}

resource "azurerm_mssql_database" "erp_db" {
  name               = "${var.environment}_erp"
  server_id          = azurerm_mssql_server.sql_server.id
  collation          = "SQL_Latin1_General_CP1_CI_AS"
  license_type       = "LicenseIncluded"
  max_size_gb        = 2
  sku_name           = "Basic"
  geo_backup_enabled = false
  zone_redundant     = false
}

resource "azurerm_mssql_virtual_network_rule" "sql_vnet_rule" {
  name      = "${var.environment}-${var.project}-sql-vnet-rule"
  server_id = azurerm_mssql_server.sql_server.id
  subnet_id = azurerm_subnet.erp_subnet.id
}
