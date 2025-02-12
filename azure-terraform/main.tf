terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.18.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.1.0"
    }
  }


}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  client_id       = var.deploy_client_id
  client_secret   = var.deploy_client_secret
  tenant_id       = var.tenant_id

}


provider "azuread" {
  tenant_id = var.tenant_id
}


data "azurerm_client_config" "current" {

}

locals {
  rg_name             = "${var.environment}-${var.project}-rg"
  location            = var.resource_group_location
  main_application_id = azuread_application.app.client_id
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = local.location
  tags     = var.tags
}

data "azuread_client_config" "current" {}

resource "random_uuid" "widgets_scope_id" {}

resource "azuread_application" "app" {
  display_name     = "${var.environment}-${var.project}"
  identifier_uris  = ["api://${var.environment}-${var.project}"]
  sign_in_audience = "AzureADMyOrg"
  # add redirect uri
  # ad application

  api {
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access ${var.environment}-${var.project} on behalf of the signed-in user."
      admin_consent_display_name = "Access ${var.environment}-${var.project}"
      enabled                    = true
      id                         = random_uuid.widgets_scope_id.result
      type                       = "User"
      user_consent_description   = "Allow the application to access ${var.environment}-${var.project} on your behalf."
      user_consent_display_name  = "Access ${var.environment}-${var.project}"
      value                      = "user_impersonation"

    }
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
  }

  web {
    homepage_url  = "https://${var.environment}-${var.project}.azurewebsites.net"
    logout_url    = "https://${var.environment}-${var.project}.azurewebsites.net/logout"
    redirect_uris = ["https://${azurerm_linux_web_app.erp.name}.azurewebsites.net/.auth/login/aad/callback"] # todo

    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }

}

resource "azuread_service_principal" "sp" {
  client_id                    = azuread_application.app.client_id
  app_role_assignment_required = false
}

resource "azuread_application_password" "app_secret" {
  application_id = azuread_application.app.id
}

# add rotation

