resource "azurerm_virtual_network" "vnet" {
  name                = "${var.environment}-${var.project}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

# Subnets

resource "azurerm_subnet" "sql_subnet" {
  name                 = "${var.environment}-${var.project}-sql-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_subnet" "erp_subnet" {
  name                 = "${var.environment}-${var.project}-erp-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
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

resource "azurerm_subnet" "sto_subnet" {
  name                 = "${var.environment}-${var.project}-sto-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]
}

# Dns

resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "${var.environment}.${var.project}.sqlazure.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

# Endpoints

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
    private_dns_zone_ids = [azurerm_private_dns_zone.sql_dns.id]
  }
}

resource "azurerm_data_factory_managed_private_endpoint" "adf_to_sql" {
  name               = "${var.environment}-${var.project}-adf-to-sql"
  data_factory_id    = azurerm_data_factory.adf.id
  target_resource_id = azurerm_mssql_server.sql_server.id
  subresource_name   = "sqlServer"

  depends_on = [
    azurerm_data_factory.adf
  ]
}

resource "azurerm_data_factory_managed_private_endpoint" "adf_to_sto" {
  name               = "${var.environment}-${var.project}-adf-to-sto"
  data_factory_id    = azurerm_data_factory.adf.id
  target_resource_id = azurerm_storage_account.storage.id
  subresource_name   = "blob"

  depends_on = [
    azurerm_data_factory.adf
  ]
}

#resource "azurerm_private_endpoint" "sto_endpoint" {
#  name                = "${var.environment}-${var.project}-sto-endpoint"
#  location            = azurerm_resource_group.rg.location
#  resource_group_name = azurerm_resource_group.rg.name
#  subnet_id           = azurerm_subnet.sto_subnet.id
#
#  private_service_connection {
#    name                           = "${var.environment}-${var.project}-storage-connection"
#    private_connection_resource_id = azurerm_storage_account.storage.id
#    subresource_names              = ["blob"]
#    is_manual_connection           = false
#  }
#}
