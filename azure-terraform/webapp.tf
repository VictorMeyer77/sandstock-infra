locals  {
  erp_login_url = "https://${var.environment}-${var.project}-wap-erp.azurewebsites.net/.auth/login/aad/callback"
}


resource "azurerm_service_plan" "svp" {
  name                = "${var.environment}-${var.project}-svp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"
  tags                = var.tags
}

resource "azurerm_linux_web_app" "erp" {
  name                = "${var.environment}-${var.project}-wap-erp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.svp.id

  site_config {
    application_stack {
      python_version = "3.12"
    }
    app_command_line = "start.sh"
  }

  identity {
    type = "SystemAssigned"
  }

  auth_settings_v2 {
    auth_enabled           = true
    require_authentication = true
    unauthenticated_action = "RedirectToLoginPage"
    default_provider       = "azureactivedirectory"

    login {
      token_store_enabled = true
      logout_endpoint = "https://dev-sandstock.azurewebsites.net/logout"
    }

    active_directory_v2 {
      client_id            = data.azuread_application.app.client_id
      tenant_auth_endpoint = "https://login.microsoftonline.com/${var.tenant_id}"
      allowed_audiences    = ["api://${var.environment}-${var.project}-wap-erp"]
      allowed_applications = [data.azuread_application.app.client_id]
    }
  }

  tags = var.tags
}
