terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.18.0"
    }
  }


}

provider "azurerm" {
  features {}

  resource_provider_registrations = "none"

  subscription_id = var.subscription_id
  client_id       = var.deploy_client_id
  client_secret   = var.deploy_client_secret
  tenant_id       = var.tenant_id

}

data "azurerm_client_config" "current" {

}

locals {
  rg_name  = "${var.environment}-${var.project}-rg"
  location = var.resource_group_location
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = local.location
  tags     = var.tags
}