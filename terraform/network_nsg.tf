resource "azurerm_network_security_group" "nsg_dbk" {
  name                = "${var.environment}-${var.project}-dbk-nsg"
  resource_group_name = azurerm_resource_group.rg_net.name
  location            = azurerm_resource_group.rg_net.location
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "nsg_dbk_aso_pub" {
  subnet_id                 = azurerm_subnet.dbk_pub_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_dbk.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_dbk_aso_pri" {
  subnet_id                 = azurerm_subnet.dbk_pri_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_dbk.id
}
