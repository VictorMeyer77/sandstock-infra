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
    "List",
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

resource "azurerm_key_vault_access_policy" "aut_kv_policy" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = azurerm_automation_account.aut.identity[0].tenant_id
  object_id = azurerm_automation_account.aut.identity[0].principal_id

  secret_permissions = [
    "List",
    "Set",
    "Get",
  ]
}

resource "azurerm_key_vault_access_policy" "wap_kv_policy" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id =  azurerm_linux_web_app.erp.identity[0].tenant_id
  object_id = azurerm_linux_web_app.erp.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
}
