resource "azurerm_databricks_workspace" "dbk" {
  name                        = "${var.environment}-${var.project}-dbk"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  managed_resource_group_name = "${var.environment}-${var.project}-rg-dbk"
  sku                         = "premium"

  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = azurerm_virtual_network.vnet.id
    private_subnet_name                                  = azurerm_subnet.dbk_pri_subnet.name
    public_subnet_name                                   = azurerm_subnet.dbk_pub_subnet.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.nsg_dbk_aso_pub.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.nsg_dbk_aso_pri.id
  }

  tags = var.tags

}

resource "databricks_secret_scope" "secret_scope" {
  name = "${var.environment}-${var.project}-dbk-kv"

  keyvault_metadata {
    resource_id = azurerm_key_vault.kv.id
    dns_name    = azurerm_key_vault.kv.vault_uri
  }
}
