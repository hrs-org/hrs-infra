terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.46.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "5c9469e7-791b-4904-b189-abd1ac5ef787"
}

# Resource group for Terraform state
resource "azurerm_resource_group" "tfstate" {
  name     = var.tfstate_resource_group_name
  location = var.location
}

# Storage account (must be globally unique, lowercase 3-24 chars)
resource "azurerm_storage_account" "tfstate" {
  name                            = var.tfstate_storage_account_name
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
}

# Blob container for state files
resource "azurerm_storage_container" "tfstate" {
  name                  = var.tfstate_container_name
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

output "tfstate_backend_config" {
  value = {
    resource_group_name  = azurerm_resource_group.tfstate.name
    storage_account_name = azurerm_storage_account.tfstate.name
    container_name       = azurerm_storage_container.tfstate.name
  }
}
