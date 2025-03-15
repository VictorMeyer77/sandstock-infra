resource "azurerm_storage_account" "storage" {
  name                       = "${var.environment}${var.project}sto"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  account_tier               = "Standard"
  account_replication_type   = "ZRS"
  is_hns_enabled             = "true"
  access_tier                = "Hot"
  https_traffic_only_enabled = true
  tags                       = var.tags

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.sto_subnet.id]
  }

  depends_on = [
    azurerm_subnet.sto_subnet
  ]

}

resource "azurerm_storage_container" "container" {
  for_each              = toset(var.containers)
  name                  = each.key
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}