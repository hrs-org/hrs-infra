variable "location" {
  description = "Azure region for the Terraform state resource group"
  type        = string
  default     = "Southeast Asia"
}

variable "tfstate_resource_group_name" {
  description = "Resource group name for Terraform state"
  type        = string
  default     = "rg-hrs-tfstate"
}

variable "tfstate_storage_account_name" {
  description = "Globally unique storage account name (lowercase letters/numbers, 3-24 chars)"
  type        = string
  default     = "hrstfstor001"
}

variable "tfstate_container_name" {
  description = "Blob container name for Terraform state"
  type        = string
  default     = "terraform-state"
}
