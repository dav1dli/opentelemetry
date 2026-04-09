# Container Apps environment resources
resource "azurerm_subnet" "aca_subnet" {
  name                 = local.aca_subnet_name
  resource_group_name  = local.rg_name
  virtual_network_name = module.vnet.name
  address_prefixes     = var.aca_subnet_address_prefix
  service_endpoints    = []

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
module "aca_environment" {
  source                       = "../modules/aca_env"
  name                         = local.aca_name
  resource_group_name              = local.rg_name
  location                         = var.location
  log_analytics_workspace_id   = azurerm_log_analytics_workspace.log_analytics_workspace.id
  infrastructure_subnet_id     = azurerm_subnet.aca_subnet.id
  aca_user_identity_name       = local.aca_user_identity
}
resource "azurerm_private_dns_zone" "aca_env_private_dns_zone" {
  name                = module.aca_environment.default_domain
  resource_group_name = local.rg_name
  tags                = var.tags
  depends_on          = [module.aca_environment]
  lifecycle {
    ignore_changes = [tags]
  }
}
resource "azurerm_private_dns_zone_virtual_network_link" "aca_env_link" {
  name                  = "link_to_${local.vnet_name}"
  resource_group_name   = local.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.aca_env_private_dns_zone.name
  virtual_network_id    = module.vnet.id
  lifecycle {
    ignore_changes = [tags]
  }
}
resource "azurerm_private_dns_a_record" "aca_env_static_ip" {
  name                = "*"
  zone_name           = module.aca_environment.default_domain
  resource_group_name = local.rg_name
  ttl                 = 300
  records             = [module.aca_environment.static_ip_address]
  depends_on          = [azurerm_private_dns_zone.aca_env_private_dns_zone, module.aca_environment]
}
resource "azurerm_monitor_diagnostic_setting" "aca_env_diag" {
  name                       = format("analytics-%s", local.aca_name)
  target_resource_id         = module.aca_environment.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
  lifecycle { ignore_changes = [metric] }
}