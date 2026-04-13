data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

data "azurerm_container_app_environment" "aca_environment" {
  name                = local.aca_name
  resource_group_name = local.rg_name
}
data "azurerm_container_app_environment_storage" "volume_db" {
  name                         = lower("sa${var.environment}${var.project}db-link")
  container_app_environment_id = data.azurerm_container_app_environment.aca_environment.id
}
data "azurerm_user_assigned_identity" "aca_user_identity" {
  name                = local.aca_user_identity
  resource_group_name = local.rg_name
}