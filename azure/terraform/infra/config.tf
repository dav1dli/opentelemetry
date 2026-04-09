terraform {
  required_providers {
    azurerm    = {
      source   = "hashicorp/azurerm"
    }
  }
backend "azurerm" {
    use_azuread_auth = true
  }
}
provider "azurerm" {
  storage_use_azuread             = true
  resource_provider_registrations = "none"
  features {}
}