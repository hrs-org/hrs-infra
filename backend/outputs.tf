output "state_rg" {
  value = azurerm_resource_group.tfstate.name
}

output "state_storage_account" {
  value = azurerm_storage_account.tfstate.name
}

output "state_container" {
  value = azurerm_storage_container.tfstate.name
}
