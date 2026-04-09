resource "azurerm_storage_account" "tfstate" {
  name                              = local.tfstate_storage_account
  resource_group_name              = local.rg_name
  location                         = var.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  infrastructure_encryption_enabled = true
  public_network_access_enabled     = true
  allow_nested_items_to_be_public   = false
  min_tls_version                   = "TLS1_2"
  tags                              = var.tags
  identity {
    type = "SystemAssigned"
  }
  lifecycle {
    ignore_changes  = [tags]
    prevent_destroy = false
  }
}
resource "azurerm_storage_container" "tfstate" {
  name                  = local.tfstate_storage_container
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}
resource "azurerm_role_assignment" "spn_storage_access" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
  depends_on           = [azurerm_storage_account.tfstate]
}