# ERP Database

resource "azurerm_mssql_database" "erp_db" {
  name               = "${var.environment}_erp"
  server_id          = azurerm_mssql_server.sql_server.id
  collation          = "SQL_Latin1_General_CP1_CI_AS"
  license_type       = "LicenseIncluded"
  max_size_gb        = 2
  sku_name           = "Basic"
  geo_backup_enabled = true
  zone_redundant     = false
}

resource "azurerm_mssql_virtual_network_rule" "sql_vnet_rule" {
  name      = "${var.environment}-${var.project}-sql-vnet-rule"
  server_id = azurerm_mssql_server.sql_server.id
  subnet_id = azurerm_subnet.erp_subnet.id
}

locals {
  erp_db_usr_name = "${var.environment}_erp_usr"
}

resource "random_password" "sql_erp_usr_pwd" {
  length           = 16
  special         = true
  upper           = true
  lower           = true
  numeric         = true
}

resource "terraform_data" "erp_db_user" {
  provisioner "local-exec" {
    command = <<EOT
    sqlcmd -S tcp:${azurerm_mssql_server.sql_server.fully_qualified_domain_name},1433 \
           -d ${azurerm_mssql_database.erp_db.name} \
           -U ${azurerm_mssql_server.sql_server.administrator_login} \
           -P '${azurerm_mssql_server.sql_server.administrator_login_password}' \
           -Q "CREATE USER ${local.erp_db_usr_name} WITH PASSWORD = '${random_password.sql_erp_usr_pwd.result}'; ALTER ROLE db_owner ADD MEMBER ${var.environment}_erp_usr;"
    EOT
  }

  depends_on = [
    azurerm_mssql_firewall_rule.sql_firewall_deploy_ip
  ]
}