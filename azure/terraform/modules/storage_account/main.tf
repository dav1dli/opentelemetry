terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}


resource "azurerm_storage_account" "storage_account" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_kind                  = var.account_kind
  account_tier                  = var.account_tier
  account_replication_type      = var.replication_type
  is_hns_enabled                = var.is_hns_enabled
  public_network_access_enabled = var.public_network_access_enabled
  allow_nested_items_to_be_public = false
  tags                          = var.tags
  network_rules {
    # default_action             = (length(var.ip_rules) + length(var.virtual_network_subnet_ids)) > 0 ? "Deny" : var.default_action
    default_action             = var.default_action
    bypass                     = ["Logging", "Metrics", "AzureServices"]
    ip_rules                   = var.ip_rules
    virtual_network_subnet_ids = var.virtual_network_subnet_ids
  }
  identity {
    type = "SystemAssigned"
  }
  blob_properties {
    delete_retention_policy {
      days = var.retention_in_days
    }
    versioning_enabled  = true
  }
  lifecycle {
    ignore_changes = [tags, public_network_access_enabled, network_rules]
    prevent_destroy = false
  }
}


resource "azurerm_monitor_diagnostic_setting" "storage_account_diag" {
  name                       = format("analytics-%s", var.name)
  target_resource_id         = azurerm_storage_account.storage_account.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  depends_on                 = [azurerm_storage_account.storage_account]
  enabled_metric {
    category = "Transaction"
  }
  lifecycle { ignore_changes = [enabled_log, enabled_metric] }
}