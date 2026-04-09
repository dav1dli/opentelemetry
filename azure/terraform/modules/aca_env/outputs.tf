output "id" {
  value = azurerm_container_app_environment.aca_environment.id
  description = "Specifies the resource id of the Container App Environment"
}

output "name" {
  value = azurerm_container_app_environment.aca_environment.name
  description = "Specifies the name of the Container App Environment"
}

output "default_domain" {
  value = azurerm_container_app_environment.aca_environment.default_domain
  description = "Specifies the default, publicly resolvable, name of the Container App Environment"
}

output "static_ip_address" {
  value = azurerm_container_app_environment.aca_environment.static_ip_address
  description = "Specifies the Static IP address of the Container App Environment"
}
output "aca_user_identity" {
  value = azurerm_user_assigned_identity.aca_user_identity
  description = "User assigned identity of the Container App Environment"
}