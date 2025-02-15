resource "azurerm_postgresql_flexible_server" "sql_server" {
  name                          = "${var.environment}-${var.project}-sql"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "16"
  administrator_login           = "psql_admin"
  administrator_password        = var.sql_db_admin_password
  storage_mb                    = 32768
  sku_name                      = "B_Standard_B1ms"
  public_network_access_enabled = true
  zone                          = "1"

  authentication {
    active_directory_auth_enabled = false
    password_auth_enabled         = true
  }

}

resource "azurerm_postgresql_flexible_server_database" "erp-db" {
  name      = "${var.environment}_erp"
  server_id = azurerm_postgresql_flexible_server.sql_server.id
  collation = "en_US.utf8"
  charset   = "UTF8"

  # prevent the possibility of accidental data loss
  #lifecycle {
  #  prevent_destroy = true
  #}
}