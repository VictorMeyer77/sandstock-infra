resource "azurerm_automation_python3_package" "azure_core" {
  name                    = "azure_core"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.aut.name
  content_uri             = "https://files.pythonhosted.org/packages/39/83/325bf5e02504dbd8b4faa98197a44cdf8a325ef259b48326a2b6f17f8383/azure_core-1.32.0-py3-none-any.whl"
  content_version         = "1.32.0"
}

resource "azurerm_automation_python3_package" "azure_identity" {
  name                    = "azure_identity"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.aut.name
  content_uri             = "https://files.pythonhosted.org/packages/3d/9f/1f9f3ef4f49729ee207a712a5971a9ca747f2ca47d9cbf13cf6953e3478a/azure_identity-1.21.0-py3-none-any.whl"
  content_version         = "1.21.0"
}