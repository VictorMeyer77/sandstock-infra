resource "azurerm_virtual_network" "vnet" {
  name                = "${var.environment}-${var.project}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "sql_subnet" {
  name                 = "${var.environment}-${var.project}-sql-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints = ["Microsoft.Sql"]
}

resource "azurerm_subnet" "erp_subnet" {
  name                 = "${var.environment}-${var.project}-erp-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints = ["Microsoft.Sql"]
  delegation {
    name = "appservice"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }
}

resource "azurerm_mssql_virtual_network_rule" "sql_vnet_rule" {
  name      = "${var.environment}-${var.project}-sql-vnet-rule"
  server_id = azurerm_mssql_server.sql_server.id
  subnet_id = azurerm_subnet.erp_subnet.id
}

resource "azurerm_private_dns_zone" "psql_dns" {
  name                = "${var.environment}.${var.project}.sqlazure.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "psql_vnet_link" {
  name                  = "${var.environment}-${var.project}-psql-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.psql_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
  depends_on            = [azurerm_subnet.sql_subnet]
}

resource "azurerm_private_endpoint" "sql_endpoint" {
  name                = "${var.environment}-${var.project}-sql-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.sql_subnet.id

  private_service_connection {
    name                           = "${var.environment}-${var.project}-sql-connection"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${var.environment}-${var.project}-sql-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.psql_dns.id]
  }
}

resource "azurerm_private_dns_a_record" "sql_dns_record" {
  name                = "${var.environment}-${var.project}-sql-dns-a"
  zone_name           = azurerm_private_dns_zone.psql_dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_endpoint.private_service_connection[0].private_ip_address]
}
