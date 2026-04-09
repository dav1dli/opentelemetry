module "acr" {
  source                        = "../modules/acr"
  name                          = local.acr_name
  resource_group_name           = local.rg_name
  location                      = var.location
  sku                           = "Premium"
  admin_enabled                 = true
  public_network_access_enabled = var.acr_public
  network_rule_set              = var.network_rule_set
  tags                          = var.tags
}

module "acr_private_dns_zone" {
  source              = "../modules/private_dns_zone"
  name                = "privatelink.azurecr.io"
  resource_group_name = local.rg_name
  virtual_network_id  = module.vnet.id
  depends_on          = [module.vnet]
}
module "acr_private_endpoint" {
  source                         = "../modules/private_endpoint"
  name                           = format("PEP-%s", local.acr_name)
  resource_group_name            = local.rg_name
  location                       = var.location
  subnet_id                      = module.vnet.subnet_ids[local.pep_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.acr.id
  is_manual_connection           = false
  subresource_name               = "registry"
  private_dns_zone_group_name    = "AcrPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.acr_private_dns_zone.id]
}

resource "azurerm_monitor_diagnostic_setting" "acr_diag" {
  name                       = format("analytics-%s", local.acr_name)
  target_resource_id         = module.acr.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
  lifecycle { ignore_changes = [enabled_metric] }
}
resource "azurerm_role_assignment" "aca_acr" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.aca_environment.aca_user_identity.principal_id
}
