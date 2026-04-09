terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}
resource "azurerm_container_registry" "acr" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  network_rule_bypass_option    = "AzureServices"
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }
  dynamic "network_rule_set" {
    for_each = try(var.network_rule_set.default_action, false) != false || try(var.network_rule_set.ip_rule, false) != false ? var.network_rule_set[*] : []
    content {
      default_action = lookup(network_rule_set.value, "default_action", false) != false ? network_rule_set.value["default_action"] : null
      dynamic "ip_rule" {
        for_each = try(network_rule_set.value.ip_rule.action, false) != false ? network_rule_set.value.ip_rule[*] : []
        content {
          action   = ip_rule.value["action"]
          ip_range = ip_rule.value["ip_range"]
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}