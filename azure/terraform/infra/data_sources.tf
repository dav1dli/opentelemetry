data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}
data "azurerm_storage_account" "tfstate" {
  name                = local.tfstate_storage_account
  resource_group_name = local.rg_name
}
data "azurerm_storage_container" "tfstate" {
  name               = local.tfstate_storage_container
  storage_account_id = data.azurerm_storage_account.tfstate.id
}