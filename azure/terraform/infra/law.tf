resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = local.log_analytics_workspace_name
  resource_group_name = local.rg_name
  location            = var.location
  retention_in_days   = 30
  tags                = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_monitor_diagnostic_setting" "sc_tfstate" {
  name                       = format("analytics-%s", local.tfstate_storage_container)
  target_resource_id         = "${data.azurerm_storage_account.tfstate.id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  depends_on                 = [data.azurerm_storage_container.tfstate]
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