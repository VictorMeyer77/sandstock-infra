resource "random_password" "sql_srv_admin_pwd" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "azurerm_mssql_server" "sql_server" {
  name                          = "${var.environment}-${var.project}-sql"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "12.0"
  administrator_login           = "sql_admin"
  administrator_login_password  = random_password.sql_srv_admin_pwd.result
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true
  tags                          = var.tags
}


resource "azurerm_mssql_firewall_rule" "sql_firewall_deploy_ip" {
  name             = "${var.environment}-${var.project}-deploy-ip"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = chomp(data.http.local_public_ip.response_body)
  end_ip_address   = chomp(data.http.local_public_ip.response_body)
}