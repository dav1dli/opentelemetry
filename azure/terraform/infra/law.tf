resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = local.log_analytics_workspace_name
  resource_group_name = local.rg_name
  location            = var.location
  retention_in_days   = 30
  tags                = var.tags
  lifecycle {
      ignore_changes = [ tags ]
  }
}