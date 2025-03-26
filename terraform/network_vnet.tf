resource "azurerm_virtual_network" "vnet" {
  name                = "${var.environment}-${var.project}-vnet"
  location            = azurerm_resource_group.rg_net.location
  resource_group_name = azurerm_resource_group.rg_net.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "sql_subnet" {
  name                 = "${var.environment}-${var.project}-sql-subnet"
  resource_group_name  = azurerm_resource_group.rg_net.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_subnet" "erp_subnet" {
  name                 = "${var.environment}-${var.project}-erp-subnet"
  resource_group_name  = azurerm_resource_group.rg_net.name
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
  resource_group_name  = azurerm_resource_group.rg_net.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]
}

resource "azurerm_subnet" "sto_dbk_subnet" {
  name                              = "${var.environment}-${var.project}-sto-dbk-subnet"
  resource_group_name               = azurerm_resource_group.rg_net.name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  address_prefixes                  = ["10.0.4.0/24"]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet" "dbk_pub_subnet" {
  name                 = "${var.environment}-${var.project}-dbk-pub-subnet"
  resource_group_name  = azurerm_resource_group.rg_net.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.5.0/24"]

  delegation {
    name = "databricks"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}

resource "azurerm_subnet" "dbk_pri_subnet" {
  name                 = "${var.environment}-${var.project}-dbk-pri-subnet"
  resource_group_name  = azurerm_resource_group.rg_net.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.6.0/24"]

  private_endpoint_network_policies = "Enabled"

  delegation {
    name = "databricks"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}