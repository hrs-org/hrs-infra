terraform {
  backend "azurerm" {
    resource_group_name  = "rg-hrs-tfstate"
    storage_account_name = "hrstfstor001"
    container_name       = "terraform-state"
    key                  = "uat.terraform.tfstate"
  }
}
