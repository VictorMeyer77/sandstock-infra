resource "azurerm_postgresql_flexible_server" "sql_server" {
  name                          = "${var.environment}-${var.project}-sql"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "16"
  delegated_subnet_id           = azurerm_subnet.sql_subnet.id
  private_dns_zone_id           = azurerm_private_dns_zone.psql_dns.id
  public_network_access_enabled = false
  administrator_login           = "psql_admin"
  administrator_password        = var.sql_db_admin_password
  zone                          = "1"
  storage_mb                    = 32768
  sku_name                      = "B_Standard_B1ms"
  storage_tier                  = "P4"
  depends_on                    = [azurerm_private_dns_zone_virtual_network_link.psql_vnet_link]
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