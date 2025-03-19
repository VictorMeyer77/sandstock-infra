resource "azurerm_automation_account" "aut" {
  name                = "${var.environment}-${var.project}-aut"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_automation_source_control" "aut_git" {
  name                    = "${var.environment}-${var.project}-aut-git"
  automation_account_id   = azurerm_automation_account.aut.id
  folder_path             = "runbook"
  automatic_sync          = true
  publish_runbook_enabled = true

  security {
    token      = var.aut_github_token
    token_type = "PersonalAccessToken"
  }

  repository_url      = var.aut_github_repository
  source_control_type = "GitHub"
  branch              = "main"

}