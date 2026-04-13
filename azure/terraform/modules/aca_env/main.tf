terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

resource "azurerm_container_app_environment" "aca_environment" {
  name                           = var.name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  infrastructure_subnet_id       = var.infrastructure_subnet_id
  internal_load_balancer_enabled = var.internal_load_balancer_enabled
  infrastructure_resource_group_name = var.infrastructure_resource_group_name
  tags                           = var.tags
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.aca_user_identity.id
    ]
  }
  workload_profile {
    maximum_count         = 0
    minimum_count         = 0
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
  lifecycle {
      ignore_changes = [
          tags
      ]
  }
}
resource "azurerm_user_assigned_identity" "aca_user_identity" {
  location            = var.location
  name                = var.aca_user_identity_name
  resource_group_name = var.resource_group_name
}
