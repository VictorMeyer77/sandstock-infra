resource "azurerm_data_factory" "adf" {
  name                            = "${var.environment}-${var.project}-adf"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  managed_virtual_network_enabled = true

  identity {
    type = "SystemAssigned"
  }

  github_configuration {
    account_name       = var.adf_github_account
    branch_name        = "main"
    repository_name    = var.adf_github_repository
    root_folder        = "/"
    publishing_enabled = true
  }

  tags = var.tags
}

resource "azurerm_data_factory_integration_runtime_azure" "adf_runtime" {
  name                    = "${var.environment}-${var.project}-runtime"
  data_factory_id         = azurerm_data_factory.adf.id
  location                = azurerm_resource_group.rg.location
  compute_type            = "General"
  core_count              = 8
  virtual_network_enabled = true
  time_to_live_min        = 10
}
