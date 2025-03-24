terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.19.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.1.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.69.0"
    }
  }
}

data "azurerm_client_config" "current" {}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  client_id       = var.deploy_client_id
  client_secret   = var.deploy_client_secret
  tenant_id       = var.tenant_id
}

provider "azuread" {
  tenant_id     = var.tenant_id
  client_id     = var.deploy_client_id
  client_secret = var.deploy_client_secret
}

provider "databricks" {
  host                        = azurerm_databricks_workspace.dbk.workspace_url
  azure_workspace_resource_id = azurerm_databricks_workspace.dbk.id
  azure_client_id             = var.deploy_client_id
  azure_client_secret         = var.deploy_client_secret
  azure_tenant_id             = var.tenant_id
}


resource "azurerm_resource_group" "rg" {
  name     = "${var.environment}-${var.project}-rg"
  location = var.resource_group_location
  tags     = var.tags
}

resource "azurerm_resource_group" "rg_net" {
  name     = "${var.environment}-${var.project}-rg-net"
  location = var.resource_group_location
  tags     = var.tags
}

resource "azurerm_resource_group" "rg_aut" {
  name     = "${var.environment}-${var.project}-rg-aut"
  location = var.resource_group_location
  tags     = var.tags
}