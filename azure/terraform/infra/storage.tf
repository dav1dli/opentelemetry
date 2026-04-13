module "storage_account_db" {
  source                        = "../modules/storage_account"
  name                          = lower("sa${var.environment}${var.project}db")
  resource_group_name           = local.rg_name
  location                      = var.location
  log_analytics_workspace_id    = azurerm_log_analytics_workspace.log_analytics_workspace.id
  public_network_access_enabled = false
  tags                          = var.tags
  default_action                = "Deny"
  virtual_network_subnet_ids    = [azurerm_subnet.aca_subnet.id]
}
resource "azurerm_role_assignment" "storage_access_aca" {
  scope                = module.storage_account_db.id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = module.aca_environment.aca_user_identity.principal_id
  depends_on           = [module.storage_account_db, module.aca_environment]
}
resource "azurerm_storage_share" "db_share" {
  name               = "volume-db"
  storage_account_id = module.storage_account_db.id
  quota              = 5
}
resource "azurerm_container_app_environment_storage" "aca_env_storage" {
  name                         = lower("sa${var.environment}${var.project}db-link")
  container_app_environment_id = module.aca_environment.id
  account_name                 = module.storage_account_db.name
  share_name                   = azurerm_storage_share.db_share.name
  access_key                   = module.storage_account_db.primary_access_key
  access_mode                  = "ReadWrite"
}

resource "azurerm_monitor_diagnostic_setting" "aca_storage_diag" {
  name                       = "analytics-volume-db"
  target_resource_id         = "${module.storage_account_db.id}/fileServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  depends_on                 = [module.storage_account_db, azurerm_log_analytics_workspace.log_analytics_workspace]
  enabled_log {
    category_group = "allLogs"
  }
  enabled_log {
    category_group = "audit"
  }
  enabled_metric {
    category = "Transaction"
  }
}
module "storage_private_dns_zone" {
  source              = "../modules/private_dns_zone"
  name                = "privatelink.file.core.windows.net"
  resource_group_name = local.rg_name
  virtual_network_id  = module.vnet.id
  tags                = var.tags
}

module "storage_private_endpoint" {
  source                         = "../modules/private_endpoint"
  name                           = format("PEP-%s", lower("sa${var.environment}${var.project}db"))
  resource_group_name            = local.rg_name
  location                       = var.location
  subnet_id                      = module.vnet.subnet_ids[local.pep_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.storage_account_db.id
  is_manual_connection           = false
  subresource_name               = "file"
  private_dns_zone_group_name    = "StoragePrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.storage_private_dns_zone.id]
}
