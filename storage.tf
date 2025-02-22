resource "azurerm_storage_account" "storage" {
  name                     = "${var.environment}${var.project}sto"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  is_hns_enabled           = "true"
  access_tier              = "Hot"
  tags                     = var.tags

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.sto_subnet.id]
  }

}

resource "azurerm_storage_container" "container" {
  for_each              = toset(var.containers)
  name                  = each.key
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}

resource "azurerm_key_vault" "kv" {
  name                        = "${var.environment}-${var.project}-kv"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  tags                        = var.tags
}

# Access Policies

resource "azurerm_key_vault_access_policy" "tenant_kv_policy" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Get",
  ]

  secret_permissions = [
    "Set",
    "Get",
    "Delete",
    "Purge",
    "Recover"
  ]
}

resource "azurerm_key_vault_access_policy" "adf_kv_policy" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = azurerm_data_factory.adf.identity[0].tenant_id
  object_id = azurerm_data_factory.adf.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
}


# Secrets

resource "azurerm_key_vault_secret" "db_usr_pwd" {
  name         = "${azurerm_mssql_server.sql_server.name}-password"
  content_type = "Password of ${azurerm_mssql_server.sql_server.administrator_login} on azure sql ${azurerm_mssql_server.sql_server.name}"
  value        = var.sql_db_admin_password
  key_vault_id = azurerm_key_vault.kv.id
}